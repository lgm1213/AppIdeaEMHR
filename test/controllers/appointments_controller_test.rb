# frozen_string_literal: true

require "test_helper"

class AppointmentsControllerTest < ActionDispatch::IntegrationTest
  # ── Setup ──────────────────────────────────────────────────────────────────
  setup do
    @organization = organizations(:one)
    @user         = users(:one)
    login_as(@user)
    @appointment  = appointments(:one)
    @patient      = patients(:one)
    @provider     = providers(:one)
  end

  # ── Index ───────────────────────────────────────────────────────────────────

  test "GET index returns success" do
    get appointments_url(slug: @organization.slug)
    assert_response :success
  end

  test "GET index with date param scopes to that date" do
    get appointments_url(slug: @organization.slug, date: "2027-01-01")
    assert_response :success
  end

  # ── New ─────────────────────────────────────────────────────────────────────

  test "GET new returns success" do
    get new_appointment_url(slug: @organization.slug)
    assert_response :success
  end

  test "GET new pre-fills patient_id from query param" do
    get new_appointment_url(slug: @organization.slug, patient_id: @patient.id)
    assert_response :success
    # The patient_id should be embedded in the form as a hidden/selected value
    assert_match @patient.id.to_s, response.body
  end

  # ── Create ──────────────────────────────────────────────────────────────────

  test "POST create with valid params creates appointment and redirects" do
    start = 2.days.from_now.change(sec: 0)
    assert_difference "Appointment.count" do
      post appointments_url(slug: @organization.slug), params: {
        appointment: {
          patient_id:  @patient.id,
          provider_id: @provider.id,
          start_time:  start,
          end_time:    start + 30.minutes,
          status:      "scheduled",
          reason:      "Annual Checkup"
        }
      }
    end
    assert_redirected_to appointments_url(slug: @organization.slug, date: start.to_date)
  end

  test "POST create with invalid params re-renders new" do
    # Missing start_time and end_time → should fail validation
    assert_no_difference "Appointment.count" do
      post appointments_url(slug: @organization.slug), params: {
        appointment: {
          patient_id:  @patient.id,
          provider_id: @provider.id,
          start_time:  nil,
          end_time:    nil
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # ── Show ─────────────────────────────────────────────────────────────────────

  test "GET show returns success" do
    get appointment_url(slug: @organization.slug, id: @appointment.id)
    assert_response :success
  end

  # ── Edit ─────────────────────────────────────────────────────────────────────

  test "GET edit returns success" do
    get edit_appointment_url(slug: @organization.slug, id: @appointment.id)
    assert_response :success
  end

  test "GET edit only offers valid forward transitions in status dropdown" do
    get edit_appointment_url(slug: @organization.slug, id: @appointment.id)
    assert_response :success
    # The dropdown must contain the current status and valid transitions
    assert_match "Scheduled", response.body
    assert_match "Confirmed", response.body
    # completed is NOT a direct transition from scheduled — must not appear
    assert_no_match(/value="completed"/, response.body)
  end

  # ── Update ───────────────────────────────────────────────────────────────────

  test "PATCH update with valid transition updates and redirects" do
    patch appointment_url(slug: @organization.slug, id: @appointment.id), params: {
      appointment: { status: "confirmed", reason: "Confirmed by staff" }
    }
    assert_redirected_to appointments_url(slug: @organization.slug, date: @appointment.start_time.to_date)
    assert @appointment.reload.confirmed?
  end

  test "PATCH update with invalid status transition re-renders edit" do
    # scheduled → completed is not a valid transition
    patch appointment_url(slug: @organization.slug, id: @appointment.id), params: {
      appointment: { status: "completed" }
    }
    assert_response :unprocessable_entity
  end

  # ── Cancel ────────────────────────────────────────────────────────────────────

  test "PATCH cancel soft-cancels a cancellable appointment" do
    patch cancel_appointment_url(slug: @organization.slug, id: @appointment.id)
    assert_redirected_to appointments_url(slug: @organization.slug, date: @appointment.start_time.to_date)
    assert @appointment.reload.cancelled?
    # Record must still exist (soft cancel, not hard delete)
    assert Appointment.exists?(@appointment.id)
  end

  test "PATCH cancel on already-cancelled appointment redirects with alert" do
    cancelled = appointments(:cancelled_appt)
    patch cancel_appointment_url(slug: @organization.slug, id: cancelled.id)
    assert_redirected_to appointment_url(slug: @organization.slug, id: cancelled.id)
    assert_equal "This appointment cannot be cancelled.", flash[:alert]
  end

  test "PATCH cancel on completed appointment redirects with alert" do
    completed = appointments(:completed_appt)
    patch cancel_appointment_url(slug: @organization.slug, id: completed.id)
    assert_redirected_to appointment_url(slug: @organization.slug, id: completed.id)
    assert_equal "This appointment cannot be cancelled.", flash[:alert]
  end

  private

  def login_as(user)
    post session_url, params: { email_address: user.email_address, password: "password" }
  end
end
