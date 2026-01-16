class Condition < ApplicationRecord
  belongs_to :patient

  # Audit Trail for Clinical Records using PaperTrail Gem
  has_paper_trail meta: { patient_id: :patient_id }

  scope :active, -> { where(status: "Active") }

  validates :name, presence: true
  validates :status, inclusion: { in: %w[Active Resolved], message: "%{value} is not a valid status" }
end
