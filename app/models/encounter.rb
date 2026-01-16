class Encounter < ApplicationRecord
  belongs_to :patient
  belongs_to :provider
  belongs_to :organization
  belongs_to :appointment, optional: true

  # Audit Trail for Clinical Records using PaperTrail Gem
  has_paper_trail meta: { patient_id: :patient_id }
end
