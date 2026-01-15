class Patient < ApplicationRecord
  belongs_to :organization

  # Clinical Visits
  has_many :encounters, dependent: :destroy
  has_many :appointments, dependent: :destroy

  # Patient Docs
  has_many :documents, dependent: :destroy

  validates :first_name, :last_name, :date_of_birth, presence: true

  def full_name
    "#{last_name}, #{first_name}"
  end
end
