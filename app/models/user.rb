class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  belongs_to :organization, optional: true

  # Medical Credentials
  has_one :provider, dependent: :destroy
  accepts_nested_attributes_for :provider

  # Enum for roles
  enum :role, [ :staff, :provider, :admin, :superadmin ]

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }


  def full_name
    "#{first_name} #{last_name}"
  end

  def initials
    f = first_name&.first || "?"
    l = last_name&.first  || "?"
    "#{f}#{l}".upcase
  end

  # Helper to check if they have a clinical profile active
  def is_provider?
    role == "provider" && provider.present?
  end
end
