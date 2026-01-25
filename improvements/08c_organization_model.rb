# frozen_string_literal: true

# ==============================================================================
# IMPROVEMENT #8c: Organization Model with inverse_of Declarations
# ==============================================================================
# File: app/models/organization.rb
#
# Changes:
# - Added inverse_of to all associations
# - Added validations for slug
# - Added helper methods
# - Improved slug generation
# ==============================================================================

class Organization < ApplicationRecord
  # ===========================================================================
  # Associations with inverse_of
  # ===========================================================================

  # Physical locations
  has_many :facilities, dependent: :destroy, inverse_of: :organization

  # Staff members
  has_many :users, dependent: :destroy, inverse_of: :organization
  has_many :providers, dependent: :destroy, inverse_of: :organization

  # Patients
  has_many :patients, dependent: :destroy, inverse_of: :organization

  # Medical Records & Billing
  has_many :appointments, dependent: :destroy, inverse_of: :organization
  has_many :encounters, dependent: :destroy, inverse_of: :organization
  has_many :procedures, dependent: :destroy, inverse_of: :organization
  has_many :messages, dependent: :destroy, inverse_of: :organization

  # Nested attributes for signup form
  accepts_nested_attributes_for :users

  # ===========================================================================
  # Validations
  # ===========================================================================
  validates :name, presence: true, length: { minimum: 2, maximum: 255 }
  validates :slug, presence: true,
                   uniqueness: { case_sensitive: false },
                   length: { minimum: 2, maximum: 100 },
                   format: {
                     with: /\A[a-z0-9]+(-[a-z0-9]+)*\z/,
                     message: "can only contain lowercase letters, numbers, and hyphens"
                   }

  # ===========================================================================
  # Callbacks
  # ===========================================================================
  before_validation :generate_slug, on: :create
  before_validation :normalize_slug

  # ===========================================================================
  # Scopes
  # ===========================================================================
  scope :active, -> { where(active: true) }
  scope :by_name, -> { order(:name) }
  scope :with_counts, -> {
    select(
      "organizations.*",
      "(SELECT COUNT(*) FROM patients WHERE patients.organization_id = organizations.id) AS patients_count",
      "(SELECT COUNT(*) FROM users WHERE users.organization_id = organizations.id) AS users_count",
      "(SELECT COUNT(*) FROM providers WHERE providers.organization_id = organizations.id) AS providers_count"
    )
  }

  # ===========================================================================
  # Instance Methods
  # ===========================================================================
  def to_param
    slug
  end

  def display_name
    name
  end

  def primary_facility
    facilities.first
  end

  def admin_users
    users.where(role: [ :admin, :superadmin ])
  end

  def clinical_staff
    users.where(role: [ :provider, :admin ])
  end

  def patient_count
    patients.count
  end

  def provider_count
    providers.count
  end

  def active_patient_count
    patients.seen_recently.count
  end

  def encounters_this_month
    encounters.this_month.count
  end

  def appointments_today
    appointments.today.count
  end

  # Dashboard stats
  def dashboard_stats
    {
      patients: patient_count,
      providers: provider_count,
      appointments_today: appointments_today,
      encounters_this_month: encounters_this_month
    }
  end

  private

  def generate_slug
    return if name.blank?
    return if slug.present?

    base_slug = name.parameterize
    candidate = base_slug
    counter = 1

    # Ensure uniqueness
    while Organization.exists?(slug: candidate)
      candidate = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = candidate
  end

  def normalize_slug
    self.slug = slug&.downcase&.strip
  end
end
