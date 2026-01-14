class Appointment < ApplicationRecord
  belongs_to :patient
  belongs_to :provider
  belongs_to :organization

  has_one :encounter

  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  # Status Workflow
  enum :status, [ :scheduled, :checked_in, :in_progress, :completed, :cancelled, :no_show ], default: :scheduled

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    if end_time < start_time
      errors.add(:end_time, "must be after the start time")
    end
  end
end
