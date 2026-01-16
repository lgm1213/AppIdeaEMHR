class CareTeamMember < ApplicationRecord
  belongs_to :patient
  belongs_to :user

  # Audit Trail for Clinical Records using PaperTrail Gem
  has_paper_trail meta: { patient_id: :patient_id }

  validates :role, presence: true
end
