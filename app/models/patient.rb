class Patient < ApplicationRecord
  belongs_to :organization

  # Clinical Visits
  has_many :encounters, dependent: :destroy
  has_many :appointments, dependent: :destroy

  # Patient Docs
  has_many :documents, dependent: :destroy

  # DISCRETE CLINICAL DATA
  has_many :allergies, dependent: :destroy
  has_many :conditions, dependent: :destroy
  has_many :medications, dependent: :destroy
  has_many :dmes, dependent: :destroy
  has_many :labs, dependent: :destroy

  validates :first_name, :last_name, :date_of_birth, presence: true

  def full_name
    "#{last_name}, #{first_name}"
  end
end
