class Encounter < ApplicationRecord
  # ===========================================================================
  # Associations with inverse_of for proper bidirectional linking
  # ===========================================================================
  belongs_to :patient, inverse_of: :encounters
  belongs_to :provider, inverse_of: :encounters
  belongs_to :organization, inverse_of: :encounters
  belongs_to :appointment, optional: true, inverse_of: :encounter

  # Bridge Models for Procedures and Diagnoses
  has_many :encounter_procedures, dependent: :destroy, inverse_of: :encounter
  has_many :encounter_diagnoses, dependent: :destroy, inverse_of: :encounter

  # --- Vitals Association ---
  has_one :vital, dependent: :destroy, inverse_of: :encounter

  # Shortcuts / Through Associations for easier access
  has_many :procedures, through: :encounter_procedures

  # ===========================================================================
  # Audit Trail
  # ===========================================================================
  has_paper_trail meta: { patient_id: :patient_id }

  # ===========================================================================
  # Nested Forms Support
  # ===========================================================================
  accepts_nested_attributes_for :encounter_procedures,
                                allow_destroy: true,
                                reject_if: :all_blank

  accepts_nested_attributes_for :encounter_diagnoses,
                                allow_destroy: true,
                                reject_if: :all_blank

  accepts_nested_attributes_for :vital,
                                allow_destroy: true,
                                reject_if: :all_blank

  # ===========================================================================
  # Enums
  # ===========================================================================
  enum :status, {
    draft: 0,
    in_progress: 1,
    completed: 2,
    signed: 3,
    amended: 4
  }, default: :draft, validate: true

  # ===========================================================================
  # Callbacks
  # ===========================================================================
  # Ensure a blank vital record exists when initializing a new form
  after_initialize :build_default_vital, if: :new_record?

  # ===========================================================================
  # Validations
  # ===========================================================================
  validates :visit_date, presence: true
  validates :provider, presence: true
  validate :provider_belongs_to_organization
  validate :patient_belongs_to_organization

  # ===========================================================================
  # Scopes
  # ===========================================================================
  scope :recent, -> { order(visit_date: :desc) }
  scope :by_date, ->(date) { where(visit_date: date.all_day) }
  scope :this_week, -> { where(visit_date: Time.current.all_week) }
  scope :this_month, -> { where(visit_date: Time.current.all_month) }
  scope :for_patient, ->(patient) { where(patient: patient) }
  scope :for_provider, ->(provider) { where(provider: provider) }
  scope :completed, -> { where(status: [ :completed, :signed ]) }
  scope :needs_signature, -> { where(status: :completed) }

  scope :with_associations, -> {
    includes(
      :provider,
      :organization,
      :appointment,
      :vital, # Include vitals in eager load
      patient: [ :conditions, :allergies ],
      encounter_procedures: :procedure,
      encounter_diagnoses: []
    )
  }

  # ===========================================================================
  # Instance Methods
  # ===========================================================================
  def total_charges
    encounter_procedures.sum(:charge_amount)
  end

  def diagnosis_codes
    encounter_diagnoses.pluck(:icd_code).compact
  end

  def procedure_codes
    procedures.pluck(:code).compact
  end

  def soap_complete?
    subjective.present? && objective.present? && assessment.present? && plan.present?
  end

  def can_be_signed?
    completed? && soap_complete?
  end

  def sign!(signer = nil)
    return false unless can_be_signed?

    transaction do
      update!(
        status: :signed,
        signed_at: Time.current,
        signed_by_id: signer&.id || provider.user_id
      )
    end
  end

  def duration_display
    return "N/A" unless appointment&.start_time && appointment&.end_time
    appointment.duration_display
  end

  def finalized?
    # Returns true if the encounter is in any "finished" state
    completed? || signed? || amended?
  end

  def total_charges
    encounter_procedures.sum(:charge_amount)
  end

  private

  def build_default_vital
    build_vital if vital.nil?
  end

  def provider_belongs_to_organization
    return unless provider && organization
    unless provider.organization_id == organization_id
      errors.add(:provider, "must belong to the same organization")
    end
  end

  def patient_belongs_to_organization
    return unless patient && organization
    unless patient.organization_id == organization_id
      errors.add(:patient, "must belong to the same organization")
    end
  end
end
