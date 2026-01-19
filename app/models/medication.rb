class Medication < ApplicationRecord
  belongs_to :patient
  belongs_to :prescribed_by, class_name: "User"

  # Audit Trail for Medication Records using PaperTrail Gem
  has_paper_trail meta: { patient_id: :patient_id }


  scope :active, -> { where(status: "Active") }

  validates :name, presence: true
  validates :status, inclusion: { in: %w[Active Discontinued Completed], message: "%{value} is not a valid status" }

  # SureScripts required validations
  validates :name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :quantity_unit, presence: true
  validates :refills, numericality: { greater_than_or_equal_to: 0 }
  validates :sig, presence: true

  # Helper for the PDF
  def formatted_sig
    "#{name} #{dosage || ''} -- #{sig} (Qty: #{quantity} #{quantity_unit}, Refills: #{refills})"
  end
end
