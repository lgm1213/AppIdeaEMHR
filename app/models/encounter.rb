class Encounter < ApplicationRecord
  belongs_to :patient
  belongs_to :provider
  belongs_to :organization
  belongs_to :appointment, optional: true

  # Audit Trail
  has_paper_trail meta: { patient_id: :patient_id }

  # Bridge Models for Procedures and Diagnoses
  has_many :encounter_procedures, dependent: :destroy
  has_many :encounter_diagnoses, dependent: :destroy

  # Nested Forms Support
  accepts_nested_attributes_for :encounter_procedures, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :encounter_diagnoses, allow_destroy: true, reject_if: :all_blank

  # Shortcuts / Through Associations for easier access
  has_many :procedures, through: :encounter_procedures

  def total_charges
    encounter_procedures.sum(:charge_amount)
  end
end
