# frozen_string_literal: true

# ==============================================================================
# IMPROVEMENT #6b: Enhanced Current Model with Organization Support
# ==============================================================================
# File: app/models/current.rb
#
# Changes:
# - Added organization attribute for tenant context
# - Added helper methods for common checks
# ==============================================================================

class Current < ActiveSupport::CurrentAttributes
  attribute :session, :organization

  delegate :user, to: :session, allow_nil: true

  # ===========================================================================
  # Helper Methods
  # ===========================================================================

  # Check if a user is currently logged in
  def self.user?
    user.present?
  end

  # Check if we're in an organization context
  def self.organization?
    organization.present?
  end

  # Get the current user's role (or nil if not logged in)
  def self.user_role
    user&.role
  end

  # Check if current user is a superadmin
  def self.superadmin?
    user&.superadmin?
  end

  # Check if current user is an admin (org-level)
  def self.admin?
    user&.admin?
  end

  # Check if current user can manage the current organization
  def self.can_manage_organization?
    return false unless user? && organization?
    user.admin? || user.superadmin?
  end

  # Reset all attributes (useful in tests)
  def self.reset!
    self.session = nil
    self.organization = nil
  end
end
