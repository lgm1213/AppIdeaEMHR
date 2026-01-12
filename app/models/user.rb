class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  belongs_to :organization, optional: true

  # Enum for roles (Simple integer mapping)
  enum :role, [ :staff, :provider, :admin, :superadmin ]


  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
