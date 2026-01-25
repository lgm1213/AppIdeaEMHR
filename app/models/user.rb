class User < ApplicationRecord
  has_secure_password

  # ===========================================================================
  # Associations
  # ===========================================================================
  has_many :sessions, dependent: :destroy
  has_many :care_team_members, dependent: :destroy
  has_many :documents, foreign_key: :uploader_id, dependent: :destroy

  belongs_to :organization, optional: true

  # Medical Credentials
  has_one :provider, dependent: :destroy
  accepts_nested_attributes_for :provider
  has_many :prescribed_medications, class_name: "Medication", foreign_key: :prescribed_by_id, dependent: :destroy

  # Messaging Associations
  has_many :sent_messages, class_name: "Message", foreign_key: "sender_id",
                           dependent: :destroy, inverse_of: :sender
  has_many :received_messages, class_name: "Message", foreign_key: "recipient_id",
                               dependent: :destroy, inverse_of: :recipient

  # ===========================================================================
  # ENUMS
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

  # ===========================================================================
  # Scopes
  # ===========================================================================
  scope :active, -> { joins(:sessions).where("sessions.created_at > ?", 30.days.ago).distinct }
  scope :by_organization, ->(org) { where(organization: org) }
  scope :clinical_staff, -> { where(role: [ :provider, :admin ]) }

  # ===========================================================================
  # Instance Methods
  # ===========================================================================

  # This ensures a user is only considered a "Provider" if they have the role
  # AND the associated medical profile record.
  def provider?
    super && provider.present?
  end

  # Deprecated alias - keeping for compatibility if your views use it,
  # but provider? is now the preferred robust check.
  def is_provider?
    provider?
  end

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

  # Role hierarchy helpers
  def can_manage_users?
    admin? || superadmin?
  end

  def can_access_billing?
    admin? || superadmin? || provider?
  end

  def can_view_clinical_data?
    !staff? || provider?
  end
end
