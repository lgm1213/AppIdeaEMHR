# frozen_string_literal: true

require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  # ── Setup ──────────────────────────────────────────────────────────────────
  # Four-Phase Test: explicit data over fixture mystery guests for critical paths.

  def valid_appointment(overrides = {})
    appointments(:one).dup.tap do |a|
      a.start_time = Time.zone.parse("2028-06-01 09:00:00")
      a.end_time   = a.start_time + 30.minutes
      a.status     = :scheduled
      overrides.each { |k, v| a.public_send(:"#{k}=", v) }
    end
  end

  # ── Associations ───────────────────────────────────────────────────────────

  test "belongs to patient" do
    assert appointments(:one).patient.present?
  end

  test "belongs to provider" do
    assert appointments(:one).provider.present?
  end

  test "belongs to organization" do
    assert appointments(:one).organization.present?
  end

  # ── Validations ────────────────────────────────────────────────────────────

  test "is valid with valid attributes" do
    appt = valid_appointment
    assert appt.valid?
  end

  test "is invalid without start_time" do
    appt = valid_appointment(start_time: nil)
    assert_not appt.valid?
    assert_includes appt.errors[:start_time], "can't be blank"
  end

  test "is invalid without end_time" do
    appt = valid_appointment(end_time: nil)
    assert_not appt.valid?
    assert_includes appt.errors[:end_time], "can't be blank"
  end

  test "is invalid when end_time is before start_time" do
    appt = valid_appointment(end_time: Time.zone.parse("2028-06-01 08:00:00"))
    assert_not appt.valid?
    assert_includes appt.errors[:end_time], "must be after the start time"
  end

  test "is invalid when end_time equals start_time" do
    t = Time.zone.parse("2028-06-01 09:00:00")
    appt = valid_appointment(start_time: t, end_time: t)
    assert_not appt.valid?
    assert_includes appt.errors[:end_time], "must be after the start time"
  end

  # ── Callbacks ──────────────────────────────────────────────────────────────

  test "sync_duration_minutes is set before save" do
    appt = valid_appointment
    appt.save!
    assert_equal 30, appt.duration_minutes
  end

  test "sync_duration_minutes updates when times change" do
    appt = appointments(:one)
    appt.end_time = appt.start_time + 60.minutes
    appt.save!
    assert_equal 60, appt.reload.duration_minutes
  end

  test "creates encounter when status transitions to completed" do
    # Setup: a checked_in appointment with no encounter
    appt = appointments(:checked_in_appt)
    assert_nil appt.encounter

    # Exercise: transition to in_progress then to completed
    appt.update!(status: :in_progress)
    assert_difference "Encounter.count", 1 do
      appt.update!(status: :completed)
    end

    # Verify: encounter is linked
    assert_not_nil appt.reload.encounter
  end

  test "does not create a duplicate encounter on re-save" do
    appt = appointments(:completed_appt)
    # Give it an existing encounter
    appt.create_encounter!(patient: appt.patient, provider: appt.provider,
                           organization: appt.organization, visit_date: appt.start_time)

    assert_no_difference "Encounter.count" do
      appt.touch  # triggers after_update but encounter already exists
    end
  end

  # ── Scopes ─────────────────────────────────────────────────────────────────

  test "upcoming scope returns only future appointments" do
    future = appointments(:one)       # start_time 2027
    past   = appointments(:completed_appt) # start_time 2026-12-15

    upcoming = Appointment.upcoming
    assert_includes upcoming, future
    assert_not_includes upcoming, past
  end

  test "past scope returns only past appointments" do
    past = appointments(:completed_appt)
    Appointment.past.tap do |scope|
      assert_includes scope, past
    end
  end

  test "active scope excludes cancelled, no_show, and rescheduled" do
    active    = appointments(:one)
    cancelled = appointments(:cancelled_appt)

    assert_includes Appointment.active, active
    assert_not_includes Appointment.active, cancelled
  end

  # ── State Machine — VALID_TRANSITIONS ──────────────────────────────────────

  test "scheduled can transition to confirmed" do
    appt = appointments(:one)
    assert appt.scheduled?
    appt.update!(status: :confirmed)
    assert appt.confirmed?
  end

  test "scheduled can transition to cancelled" do
    appt = appointments(:one)
    appt.update!(status: :cancelled)
    assert appt.cancelled?
  end

  test "invalid transition raises validation error" do
    # Setup: scheduled → completed is not a valid transition
    appt = appointments(:one)
    appt.status = :completed
    assert_not appt.valid?
    assert_match(/cannot transition from Scheduled to Completed/, appt.errors.full_messages.join)
  end

  test "completed status is a terminal state" do
    appt = appointments(:completed_appt)
    # completed → anything is invalid
    appt.status = :cancelled
    assert_not appt.valid?
  end

  test "cancelled appointment can be rebooked to scheduled" do
    appt = appointments(:cancelled_appt)
    appt.update!(status: :scheduled)
    assert appt.scheduled?
  end

  # ── Instance Methods ────────────────────────────────────────────────────────

  test "duration_display returns minutes for durations under an hour" do
    appt = appointments(:one) # 30 minutes
    assert_equal "30m", appt.duration_display
  end

  test "duration_display returns hours for exactly 60 minutes" do
    appt = appointments(:completed_appt) # 45 minutes — tweak for test
    appt.duration_minutes = 60
    assert_equal "1h", appt.duration_display
  end

  test "duration_display returns hours and minutes for mixed durations" do
    appt = appointments(:one)
    appt.duration_minutes = 90
    assert_equal "1h 30m", appt.duration_display
  end

  test "time_range_display returns TBD when times are nil" do
    appt = Appointment.new
    assert_equal "TBD", appt.time_range_display
  end

  test "can_check_in? is false for appointments far in the future" do
    appt = appointments(:one) # 2027 — well outside CHECK_IN_WINDOW
    assert_not appt.can_check_in?
  end

  test "can_check_in? is true within CHECK_IN_WINDOW for scheduled appointment" do
    appt = appointments(:one).dup
    appt.start_time = 10.minutes.from_now
    appt.end_time   = appt.start_time + 30.minutes
    appt.status     = :scheduled
    assert appt.can_check_in?
  end

  test "can_cancel? is true for scheduled appointments" do
    assert appointments(:one).can_cancel?
  end

  test "can_cancel? is false for completed appointments" do
    assert_not appointments(:completed_appt).can_cancel?
  end

  test "can_cancel? is false for already-cancelled appointments" do
    assert_not appointments(:cancelled_appt).can_cancel?
  end

  test "can_start? is true only when checked_in" do
    assert appointments(:checked_in_appt).can_start?
    assert_not appointments(:one).can_start?
  end
end
