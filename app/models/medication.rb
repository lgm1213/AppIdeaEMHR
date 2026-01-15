class Medication < ApplicationRecord
  belongs_to :patient
  belongs_to :prescribed_by, class_name: "User"

  validates :name, presence: true
  validates :status, inclusion: { in: %w[Active Discontinued Completed], message: "%{value} is not a valid status" }
end
