# frozen_string_literal: true

class Appointment < ApplicationRecord
  # ── Constants ──────────────────────────────────────────────────────────────
  # Business rule: how far ahead of an appointment start time check-in is allowed.
  CHECK_IN_WINDOW = 15.minutes.freeze

  # ── Associations ───────────────────────────────────────────────────────────
  belongs_to :patient,      inverse_of: :appointments
  belongs_to :provider,     inverse_of: :appointments
  belongs_to :organization, inverse_of: :appointments

  has_one :encounter, dependent: :nullify

  # ── Audit Trail ────────────────────────────────────────────────────────────
  has_paper_trail meta: { patient_id: :patient_id }

  # ── Enum ───────────────────────────────────────────────────────────────────
  # NEVER reorder or change these integer values in production.
  enum :status, {
    scheduled:   0,
    confirmed:   1,
    checked_in:  2,
    in_progress: 3,
    completed:   4,
    cancelled:   5,
    no_show:     6,
    rescheduled: 7
  }, default: :scheduled, validate: true

  # ── Callbacks ──────────────────────────────────────────────────────────────
  # Sync the persisted duration_minutes column whenever times change.
  before_save :sync_duration_minutes
  # Auto-create an encounter shell when an appointment is marked completed.
  after_update :create_encounter_if_completed, if: :saved_change_to_status?

  # ── Validations ────────────────────────────────────────────────────────────
  validates :start_time, presence: true
  validates :end_time,   presence: true
  validate  :end_time_after_start_time
  validate  :no_overlapping_appointments, on: :create
  validate  :valid_status_transition,     on: :update

  # ── Scopes ─────────────────────────────────────────────────────────────────
  scope :upcoming,        -> { where("start_time > ?", Time.current).order(:start_time) }
  scope :past,            -> { where("end_time < ?", Time.current).order(start_time: :desc) }
  scope :today,           -> { where(start_time: Time.current.all_day) }
  scope :this_week,       -> { where(start_time: Time.current.all_week) }
  scope :for_date,        ->(date) { where(start_time: date.all_day) }
  scope :active,          -> { where.not(status: [ :cancelled, :no_show, :rescheduled ]) }
  scope :needs_attention, -> {
    where(status: [ :scheduled, :confirmed ])
      .where("start_time < ?", CHECK_IN_WINDOW.from_now)
  }

  # ── Instance Methods ───────────────────────────────────────────────────────

  # duration_minutes is now a persisted column kept in sync by before_save.
  # The computed method has been removed to avoid shadowing the attribute reader.

  def duration_display
    mins = duration_minutes.to_i
    if mins >= 60
      hours     = mins / 60
      remaining = mins % 60
      remaining > 0 ? "#{hours}h #{remaining}m" : "#{hours}h"
    else
      "#{mins}m"
    end
  end

  def time_range_display
    return "TBD" unless start_time && end_time
    "#{start_time.strftime('%l:%M %p')} – #{end_time.strftime('%l:%M %p')}".strip
  end

  def can_check_in?
    (scheduled? || confirmed?) && start_time <= CHECK_IN_WINDOW.from_now
  end

  def can_cancel?
    !completed? && !cancelled? && !no_show?
  end

  def can_start?
    checked_in?
  end

  # ── Valid Status Transitions ───────────────────────────────────────────────
  VALID_TRANSITIONS = {
    scheduled:   [ :confirmed, :checked_in, :cancelled, :rescheduled, :no_show ],
    confirmed:   [ :checked_in, :cancelled, :rescheduled, :no_show ],
    checked_in:  [ :in_progress, :cancelled, :no_show ],
    in_progress: [ :completed, :cancelled ],
    completed:   [],
    cancelled:   [ :scheduled ],                # Allow rebooking
    no_show:     [ :scheduled ],                # Allow rebooking
    rescheduled: [ :cancelled ]                 # Allow closing out an erroneous reschedule
  }.freeze

  private

  def sync_duration_minutes
    return unless start_time && end_time
    self.duration_minutes = ((end_time - start_time) / 1.minute).to_i
  end

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?
    errors.add(:end_time, "must be after the start time") if end_time <= start_time
  end

  def no_overlapping_appointments
    return unless provider && start_time && end_time

    overlapping = provider.appointments
                          .where.not(id: id)
                          .where.not(status: [ :cancelled, :no_show, :rescheduled ])
                          .where("start_time < ? AND end_time > ?", end_time, start_time)

    errors.add(:base, "Provider already has an appointment during this time slot") if overlapping.exists?
  end

  def valid_status_transition
    return unless status_changed?

    old_status = status_was&.to_sym
    new_status = status.to_sym

    return if old_status.nil?

    allowed = VALID_TRANSITIONS[old_status] || []
    unless allowed.include?(new_status)
      errors.add(:status, "cannot transition from #{old_status.to_s.humanize} to #{new_status.to_s.humanize}")
    end
  end

  def create_encounter_if_completed
    return unless completed? && encounter.nil?

    create_encounter!(
      patient:      patient,
      provider:     provider,
      organization: organization,
      visit_date:   start_time
    )
  end
end
