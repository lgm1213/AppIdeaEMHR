# frozen_string_literal: true

# ==============================================================================
# IMPROVEMENT #4b: Appointment Model with Explicit Enum Values
# ==============================================================================
# File: app/models/appointment.rb
#
# Changes:
# - Changed enum from array to hash with explicit integer values
# - Added scopes for common queries
# - Added duration calculation
# - Added status transition validations
# ==============================================================================

class Appointment < ApplicationRecord
  belongs_to :patient
  belongs_to :provider
  belongs_to :organization

  has_one :encounter, dependent: :nullify

  # ===========================================================================
  # ENUM WITH EXPLICIT VALUES
  # ===========================================================================
  # Using a hash ensures database values stay consistent even if order changes.
  # NEVER reorder or change these integer values in production!
  # ===========================================================================
  enum :status, {
    scheduled: 0,
    confirmed: 1,
    checked_in: 2,
    in_progress: 3,
    completed: 4,
    cancelled: 5,
    no_show: 6,
    rescheduled: 7
  }, default: :scheduled, validate: true

  # ===========================================================================
  # Validations
  # ===========================================================================
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time
  validate :no_overlapping_appointments, on: :create
  validate :valid_status_transition, on: :update

  # ===========================================================================
  # Scopes
  # ===========================================================================
  scope :upcoming, -> { where("start_time > ?", Time.current).order(:start_time) }
  scope :past, -> { where("end_time < ?", Time.current).order(start_time: :desc) }
  scope :today, -> { where(start_time: Time.current.all_day) }
  scope :this_week, -> { where(start_time: Time.current.all_week) }
  scope :for_date, ->(date) { where(start_time: date.all_day) }
  scope :active, -> { where.not(status: [ :cancelled, :no_show, :rescheduled ]) }
  scope :needs_attention, -> { where(status: [ :scheduled, :confirmed ]).where("start_time < ?", 15.minutes.from_now) }

  # ===========================================================================
  # Callbacks
  # ===========================================================================
  after_update :create_encounter_if_completed, if: :saved_change_to_status?

  # ===========================================================================
  # Instance Methods
  # ===========================================================================
  def duration_minutes
    return 0 unless start_time && end_time
    ((end_time - start_time) / 1.minute).to_i
  end

  def duration_display
    mins = duration_minutes
    if mins >= 60
      hours = mins / 60
      remaining = mins % 60
      remaining > 0 ? "#{hours}h #{remaining}m" : "#{hours}h"
    else
      "#{mins}m"
    end
  end

  def time_range_display
    return "TBD" unless start_time && end_time
    "#{start_time.strftime('%l:%M %p')} - #{end_time.strftime('%l:%M %p')}".strip
  end

  def can_check_in?
    (scheduled? || confirmed?) && start_time <= 15.minutes.from_now
  end

  def can_cancel?
    !completed? && !cancelled? && !no_show?
  end

  def can_start?
    checked_in?
  end

  # Status display with color coding (for views)
  def status_badge_class
    case status
    when "scheduled" then "bg-blue-100 text-blue-800"
    when "confirmed" then "bg-green-100 text-green-800"
    when "checked_in" then "bg-yellow-100 text-yellow-800"
    when "in_progress" then "bg-purple-100 text-purple-800"
    when "completed" then "bg-gray-100 text-gray-800"
    when "cancelled", "no_show" then "bg-red-100 text-red-800"
    when "rescheduled" then "bg-orange-100 text-orange-800"
    else "bg-gray-100 text-gray-800"
    end
  end

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after the start time")
    end
  end

  def no_overlapping_appointments
    return unless provider && start_time && end_time

    overlapping = provider.appointments
                          .where.not(id: id)
                          .where.not(status: [ :cancelled, :no_show, :rescheduled ])
                          .where("start_time < ? AND end_time > ?", end_time, start_time)

    if overlapping.exists?
      errors.add(:base, "Provider already has an appointment during this time slot")
    end
  end

  # Valid status transitions
  VALID_TRANSITIONS = {
    scheduled: [ :confirmed, :checked_in, :cancelled, :rescheduled, :no_show ],
    confirmed: [ :checked_in, :cancelled, :rescheduled, :no_show ],
    checked_in: [ :in_progress, :cancelled, :no_show ],
    in_progress: [ :completed, :cancelled ],
    completed: [],
    cancelled: [ :scheduled ], # Allow rebooking
    no_show: [ :scheduled ],   # Allow rebooking
    rescheduled: []
  }.freeze

  def valid_status_transition
    return unless status_changed?

    old_status = status_was&.to_sym
    new_status = status.to_sym

    return if old_status.nil? # New record

    allowed = VALID_TRANSITIONS[old_status] || []
    unless allowed.include?(new_status)
      errors.add(:status, "cannot transition from #{old_status} to #{new_status}")
    end
  end

  def create_encounter_if_completed
    return unless completed? && encounter.nil?

    # Auto-create an encounter shell when appointment is completed
    # Provider can fill in the clinical details later
    create_encounter!(
      patient: patient,
      provider: provider,
      organization: organization,
      visit_date: start_time
    )
  end
end
