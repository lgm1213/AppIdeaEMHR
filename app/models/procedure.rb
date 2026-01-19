class Procedure < ApplicationRecord
  has_many :encounter_procedures
  has_many :encounters, through: :encounter_procedures

  validates :code, presence: true, uniqueness: true

  def display_name
    "#{code} - #{name} ($#{price})"
  end
end
