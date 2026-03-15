class Message < ApplicationRecord
  belongs_to :organization
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  belongs_to :patient, optional: true
  has_many_attached :attachments

  validates :subject, :body, presence: true

  # Scopes for easy filtering
  scope :unread, -> { where(read_at: nil) }
  scope :chronological, -> { order(created_at: :desc) }

  def mark_as_read!(reader)
    update(read_at: Time.current) if recipient_id == reader.id && read_at.nil?
  end
end
