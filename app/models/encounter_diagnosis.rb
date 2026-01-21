class EncounterDiagnosis < ApplicationRecord
  # This connects the diagnosis to the visit
  belongs_to :encounter

  # Optional: Validations to ensure data quality
  validates :icd_code, presence: true
end
