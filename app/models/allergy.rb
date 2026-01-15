class Allergy < ApplicationRecord
  belongs_to :patient

  validates :name, presence: true
  validates :severity, inclusion: { in: %w[Mild Moderate Severe Unknown], message: "%{value} is not a valid severity" }
  validates :status, inclusion: { in: %w[Active Inactive], message: "%{value} is not a valid status" }
end
