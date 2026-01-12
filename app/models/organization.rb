class Organization < ApplicationRecord
  # An organization has many physical locations (facilities)
  has_many :facilities, dependent: :destroy

  # An organization has many staff members
  has_many :users, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end
