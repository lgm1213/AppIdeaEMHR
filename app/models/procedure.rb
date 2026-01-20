class Procedure < ApplicationRecord
  belongs_to :organization

  has_many :encounter_procedures
  has_many :encounters, through: :encounter_procedures

  # Validation scope ensures uniqueness is checked per organization, not globally
  validates :code, presence: true, uniqueness: { scope: :organization_id }
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def display_name
    "#{code} - #{name} ($#{price})"
  end
end
