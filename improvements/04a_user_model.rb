# frozen_string_literal: true

# ==============================================================================
# IMPROVEMENT #4a: User Model with Explicit Enum Values
# ==============================================================================
# File: app/models/user.rb
#
# Changes:
# - Changed enum from array to hash with explicit integer values
# - Added role helper methods
# - Added scope for active users
# - Added validation for password complexity (optional)
# ==============================================================================

class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  belongs_to :organization, optional: true

  # Medical Credentials
  has_one :provider, dependent: :destroy
  accepts_nested_attributes_for :provider

  # Messaging Associations
  has_many :sent_messages, class_name: "Message", foreign_key: "sender_id",
                           dependent: :destroy, inverse_of: :sender
  has_many :received_messages, class_name: "Message", foreign_key: "recipient_id",
                               dependent: :destroy, inverse_of: :recipient

  # ===========================================================================
  # ENUM WITH EXPLICIT VALUES
  # ===========================================================================
  # Using a hash ensures database values stay consistent even if order changes.
  # NEVER reorder or change these integer values in production!
  # ===========================================================================
  enum :role, {
    staff: 0,
    provider: 1,
    admin: 2,
    superadmin: 3
  }, default: :staff, validate: true

  # ===========================================================================
  # Validations
  # ===========================================================================
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  validates :first_name, :last_name, presence: true, on: :update

  # Optional: Password complexity validation
  # Uncomment if you want to enforce strong passwords
  # validates :password, length: { minimum: 8 },
  #                      format: {
  #                        with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
  #                        message: "must include uppercase, lowercase, and a number"
  #                      },
  #                      if: -> { password.present? }

  # ===========================================================================
  # Scopes
  # ===========================================================================
  scope :active, -> { joins(:sessions).where("sessions.created_at > ?", 30.days.ago).distinct }
  scope :by_organization, ->(org) { where(organization: org) }
  scope :clinical_staff, -> { where(role: [ :provider, :admin ]) }

  # ===========================================================================
  # Instance Methods
  # ===========================================================================
  def full_name
    "#{first_name} #{last_name}".strip.presence || email_address
  end

  def initials
    f = first_name&.first || "?"
    l = last_name&.first || "?"
    "#{f}#{l}".upcase
  end

  def unread_messages_count
    received_messages.where(read_at: nil).count
  end

  # Helper to check if they have a clinical profile active
  def is_provider?
    provider? && provider_record.present?
  end

  # Alias to avoid confusion with the enum method `provider?`
  def provider_record
    # `provider` is both an enum value AND an association name
    # This returns the Provider model instance
    Provider.find_by(user_id: id)
  end

  # Role hierarchy helpers
  def can_manage_users?
    admin? || superadmin?
  end

  def can_access_billing?
    admin? || superadmin? || provider?
  end

  def can_view_clinical_data?
    !staff? || provider_record.present?
  end
end
