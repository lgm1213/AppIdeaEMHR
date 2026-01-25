# frozen_string_literal: true

# ==============================================================================
# IMPROVEMENT #10b: OrganizationScoped Concern (Without Default Scope)
# ==============================================================================
# File: app/models/concerns/organization_scoped.rb
#
# This is a SAFER alternative that doesn't use default_scope.
# Instead, it provides explicit scopes and helper methods.
#
# Usage:
#   class Patient < ApplicationRecord
#     include OrganizationScoped
#   end
#
#   # In controller:
#   @patients = Patient.for_current_organization
#   # or
#   @patients = @current_organization.patients
# ==============================================================================

module OrganizationScoped
  extend ActiveSupport::Concern

  included do
    # ===========================================================================
    # Association
    # ===========================================================================
    belongs_to :organization, inverse_of: model_name.plural.to_sym

    # ===========================================================================
    # Validations
    # ===========================================================================
    validates :organization, presence: true
    validate :organization_cannot_change, on: :update

    # ===========================================================================
    # Scopes
    # ===========================================================================

    # Primary scope for filtering by current organization
    # Usage: Patient.for_current_organization
    scope :for_current_organization, -> {
      if Current.respond_to?(:organization) && Current.organization.present?
        where(organization: Current.organization)
      else
        raise OrganizationScopingError, "Current.organization is not set"
      end
    }

    # Explicit scope for a specific organization
    # Usage: Patient.for_organization(org)
    scope :for_organization, ->(org) { where(organization: org) }

    # Safe scope that returns empty relation if no current org
    # Usage: Patient.scoped_to_current_organization
    scope :scoped_to_current_organization, -> {
      if Current.respond_to?(:organization) && Current.organization.present?
        where(organization: Current.organization)
      else
        none
      end
    }

    # ===========================================================================
    # Callbacks
    # ===========================================================================
    before_validation :set_organization_from_current, on: :create

    private

    def set_organization_from_current
      return if organization_id.present?
      return unless Current.respond_to?(:organization)

      self.organization = Current.organization
    end

    def organization_cannot_change
      return unless organization_id_changed?
      return if organization_id_was.nil?

      errors.add(:organization, "cannot be changed after creation")
    end
  end

  # ===========================================================================
  # Instance Methods
  # ===========================================================================

  # Check if this record belongs to the given organization
  def belongs_to_organization?(org)
    organization_id == org&.id
  end

  # Check if this record belongs to the current organization
  def belongs_to_current_organization?
    return false unless Current.respond_to?(:organization)
    belongs_to_organization?(Current.organization)
  end

  # ===========================================================================
  # Class Methods
  # ===========================================================================
  class_methods do
    # Find a record ensuring it belongs to the current organization
    # Raises ActiveRecord::RecordNotFound if not found or wrong org
    def find_for_current_organization(id)
      for_current_organization.find(id)
    end

    # Find a record within a specific organization
    def find_for_organization(id, organization)
      for_organization(organization).find(id)
    end

    # Safe find that returns nil instead of raising
    def find_for_current_organization_or_nil(id)
      for_current_organization.find_by(id: id)
    rescue OrganizationScopingError
      nil
    end

    # Check if a record exists in current organization
    def exists_for_current_organization?(id)
      for_current_organization.exists?(id: id)
    rescue OrganizationScopingError
      false
    end

    # Create a record automatically scoped to current organization
    def create_for_current_organization(attributes = {})
      raise OrganizationScopingError, "Current.organization is not set" unless Current.organization

      create(attributes.merge(organization: Current.organization))
    end

    def create_for_current_organization!(attributes = {})
      raise OrganizationScopingError, "Current.organization is not set" unless Current.organization

      create!(attributes.merge(organization: Current.organization))
    end
  end

  # Custom error for scoping issues
  class OrganizationScopingError < StandardError; end
end
