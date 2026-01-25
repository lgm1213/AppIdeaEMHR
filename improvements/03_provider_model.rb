# frozen_string_literal: true

# ==============================================================================
# IMPROVEMENT #3: Fix Redundant full_name in Provider Model
# ==============================================================================
# File: app/models/provider.rb
#
# Changes:
# - Removed redundant full_name override that conflicted with delegation
# - Added professional_name for "Dr. LastName" format
# - Added formal_name for "Dr. FirstName LastName" format
# - Clarified delegation and method purposes
# ==============================================================================

class Provider < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  has_many :encounters, dependent: :restrict_with_error
  has_many :appointments, dependent: :restrict_with_error

  # Validations
  validates :npi, presence: true,
                  length: { is: 10 },
                  numericality: { only_integer: true },
                  uniqueness: { scope: :organization_id, message: "already exists in this organization" }
  validates :license_number, presence: true

  # Delegate basic name methods to user
  # Use these when you need the provider's actual name (e.g., forms, data exports)
  delegate :first_name, :last_name, :email_address, to: :user, allow_nil: true

  # Full name from user (e.g., "John Smith")
  def full_name
    user&.full_name || "Unknown Provider"
  end

  # Professional title format (e.g., "Dr. Smith")
  # Use this for informal/short displays
  def professional_name
    "Dr. #{last_name}"
  end

  # Formal professional name (e.g., "Dr. John Smith")
  # Use this for formal documents, letters
  def formal_name
    "Dr. #{first_name} #{last_name}"
  end

  # Display name with credentials (e.g., "Dr. John Smith (NPI: 1234567890)")
  # Use this for dropdowns, selection lists
  def display_name
    "#{formal_name} (NPI: #{npi})"
  end

  # Short display for tight spaces (e.g., "Dr. Smith - Cardiology")
  def display_name_short
    specialty.present? ? "#{professional_name} - #{specialty}" : professional_name
  end

  # Signature line for documents
  def signature_line
    lines = [ formal_name ]
    lines << specialty if specialty.present?
    lines << "NPI: #{npi}"
    lines << "License: #{license_number}"
    lines.join("\n")
  end
end
