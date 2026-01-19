class Encounter < ApplicationRecord
  belongs_to :patient
  belongs_to :provider
  belongs_to :organization
  belongs_to :appointment, optional: true

  # Audit Trail for Clinical Records using PaperTrail Gem
  has_paper_trail meta: { patient_id: :patient_id }

  # Billing Procedures Associated with the Encounter
  has_many :encounter_procedures, dependent: :destroy
  has_many :procedures, through: :encounter_procedures

  accepts_nested_attributes_for :encounter_procedures, allow_destroy: true, reject_if: :all_blank

  def total_charges
    encounter_procedures.sum(:charge_amount)
  end
end
