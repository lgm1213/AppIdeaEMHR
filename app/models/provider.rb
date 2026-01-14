class Provider < ApplicationRecord
  belongs_to :user
  belongs_to :organization
  has_many :encounters
  has_many :appointments

  validates :npi, presence: true, length: { is: 10 }
  validates :license_number, presence: true

  # Delegate name methods to the user for convenience
  delegate :first_name, :last_name, :full_name, :email_address, to: :user, allow_nil: true

  def full_name
    "Dr. #{user&.last_name}"
  end
end
