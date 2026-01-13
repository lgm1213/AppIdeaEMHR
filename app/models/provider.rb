class Provider < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  validates :npi, presence: true, length: { is: 10 }
  validates :license_number, presence: true

  # Delegate name methods to the user for convenience
  delegate :email_address, :first_name, :last_name, to: :user, allow_nil: true

  def full_name
    "Dr. #{user&.last_name}"
  end
end
