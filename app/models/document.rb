class Document < ApplicationRecord
  belongs_to :patient
  belongs_to :uploader, class_name: "User"

  has_one_attached :file

  validate :acceptable_file

  def file_type
    if file.attached?
      file.content_type.split("/").last.upcase
    else
      "MISSING"
    end
  end

  def file_size
    return 0 unless file.attached?
    (file.byte_size / 1024.0).round(1)
  end

  private

  def acceptable_file
    return unless file.attached?

    unless file.byte_size <= 20.megabytes
      errors.add(:file, "is too big. Maximum size is 20MB.")
    end

    acceptable_types = [ "image/jpeg", "image/png", "application/pdf", "text/plain" ]
    unless acceptable_types.include?(file.content_type)
      errors.add(:file, "must be a JPEG, PNG, PDF, or TXT file.")
    end
  end
end
