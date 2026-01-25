# frozen_string_literal: true

# ==============================================================================
# IMPROVEMENT #8b: Patient Model with inverse_of Declarations
# ==============================================================================
# File: app/models/patient.rb
#
# Changes:
# - Added inverse_of to all associations
# - Added more robust validations
# - Added useful scopes
# - Added helper methods for clinical data
# ==============================================================================

class Patient < ApplicationRecord
  # ===========================================================================
  # Associations with inverse_of
  # ===========================================================================
  belongs_to :organization, inverse_of: :patients

  # Clinical Visits
  has_many :encounters, dependent: :destroy, inverse_of: :patient
  has_many :appointments, dependent: :destroy, inverse_of: :patient

  # Patient Docs
  has_many :documents, dependent: :destroy, inverse_of: :patient
  has_many :messages, dependent: :destroy, inverse_of: :patient

  # Discrete Clinical Data
  has_many :allergies, dependent: :destroy, inverse_of: :patient
  has_many :conditions, dependent: :destroy, inverse_of: :patient
  has_many :medications, dependent: :destroy, inverse_of: :patient
  has_many :dmes, dependent: :destroy, inverse_of: :patient
  has_many :labs, dependent: :destroy, inverse_of: :patient

  # Care Teams
  has_many :care_team_members, dependent: :destroy, inverse_of: :patient
  has_many :providers, through: :care_team_members, source: :user

  # ===========================================================================
  # Validations
  # ===========================================================================
  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :date_of_birth, presence: true
  validate :date_of_birth_not_in_future
  validates :email,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            allow_blank: true
  validates :phone, length: { maximum: 20 }, allow_blank: true
  validates :zip_code, length: { maximum: 10 }, allow_blank: true

  # ===========================================================================
  # Normalizations
  # ===========================================================================
  normalizes :email, with: ->(e) { e&.strip&.downcase }
  normalizes :first_name, :last_name, with: ->(n) { n&.strip&.titleize }
  normalizes :phone, with: ->(p) { p&.gsub(/[^\d]/, "") }

  # ===========================================================================
  # Scopes
  # ===========================================================================
  scope :search, ->(query) {
    where(
      "first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q",
      q: "%#{query}%"
    )
  }
  scope :by_name, -> { order(:last_name, :first_name) }
  scope :recent, -> { order(created_at: :desc) }
  scope :seen_recently, -> {
    joins(:encounters)
      .where("encounters.visit_date > ?", 1.year.ago)
      .distinct
  }
  scope :not_seen_recently, -> {
    left_joins(:encounters)
      .where(encounters: { id: nil })
      .or(
        left_joins(:encounters)
          .where("encounters.visit_date < ?", 1.year.ago)
      )
      .distinct
  }

  # ===========================================================================
  # Instance Methods - Name Helpers
  # ===========================================================================
  def full_name
    "#{last_name}, #{first_name}"
  end

  def display_name
    "#{first_name} #{last_name}"
  end

  def formal_name
    "#{last_name}, #{first_name}"
  end

  def initials
    "#{first_name&.first}#{last_name&.first}".upcase
  end

  # ===========================================================================
  # Instance Methods - Age Calculation
  # ===========================================================================
  def age
    return nil unless date_of_birth
    now = Time.current.to_date
    age = now.year - date_of_birth.year
    age -= 1 if now < date_of_birth + age.years
    age
  end

  def age_display
    return "Unknown" unless date_of_birth

    years = age
    if years < 1
      months = ((Time.current.to_date - date_of_birth) / 30).to_i
      months < 1 ? "Newborn" : "#{months} months"
    elsif years < 2
      "#{years} year"
    else
      "#{years} years"
    end
  end

  def minor?
    age.present? && age < 18
  end

  def pediatric?
    age.present? && age < 18
  end

  def geriatric?
    age.present? && age >= 65
  end

  # ===========================================================================
  # Instance Methods - Clinical Data Helpers
  # ===========================================================================
  def active_allergies
    allergies.where(status: "active")
  end

  def active_medications
    medications.where(status: "active")
  end

  def active_conditions
    conditions.where(status: "active")
  end

  def has_allergies?
    allergies.exists?
  end

  def has_no_known_allergies?
    !has_allergies?
  end

  def last_encounter
    encounters.order(visit_date: :desc).first
  end

  def last_visit_date
    last_encounter&.visit_date
  end

  def next_appointment
    appointments.upcoming.first
  end

  def primary_care_provider
    care_team_members.find_by(role: "Primary Care Provider")&.user
  end

  # ===========================================================================
  # Instance Methods - Address Helpers
  # ===========================================================================
  def full_address
    [ street_address, city, state, zip_code ].compact.reject(&:blank?).join(", ")
  end

  def city_state_zip
    parts = []
    parts << city if city.present?
    parts << state if state.present?
    city_state = parts.join(", ")
    zip_code.present? ? "#{city_state} #{zip_code}" : city_state
  end

  private

  def date_of_birth_not_in_future
    return unless date_of_birth.present?
    if date_of_birth > Date.current
      errors.add(:date_of_birth, "cannot be in the future")
    end
  end
end
