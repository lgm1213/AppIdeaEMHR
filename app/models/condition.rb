class Condition < ApplicationRecord
  belongs_to :patient

  validates :name, presence: true
  validates :status, inclusion: { in: %w[Active Resolved], message: "%{value} is not a valid status" }
end
