class Organization < ApplicationRecord
  # An organization has many physical locations (facilities)
  has_many :facilities, dependent: :destroy

  # An organization has many staff members
  has_many :users, dependent: :destroy
  has_many :providers, dependent: :destroy

  # An organization has many patients in its care
  has_many :patients, dependent: :destroy


  # Medical Encounters and Billing
  has_many :appointments
  has_many :encounters


  # Allow the signup form to create the Admin User at the same time
  accepts_nested_attributes_for :users

  validates :name, presence: true

  # Creates the URL slug based on the organization name
  before_validation :generate_slug, on: :create
  validates :slug, presence: true, uniqueness: true

  private

  def generate_slug
    return if name.blank?
    # Create a URL-safe version of the name
    self.slug = name.parameterize
  end
end
