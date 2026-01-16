class Allergy < ApplicationRecord
  belongs_to :patient

  # Audit Trail for Clinical Records using PaperTrail Gem
  has_paper_trail meta: { patient_id: :patient_id }

  validates :name, presence: true
  validates :severity, inclusion: { in: %w[Mild Moderate Severe Unknown], message: "%{value} is not a valid severity" }
  validates :status, inclusion: { in: %w[Active Inactive], message: "%{value} is not a valid status" }
end
