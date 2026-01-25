# frozen_string_literal: true

# ==============================================================================
# IMPROVEMENT #10: OrganizationScoped Concern
# ==============================================================================
# File: app/models/concerns/organization_scoped.rb
#
# This concern provides automatic organization scoping for multi-tenant models.
# USE WITH CAUTION: Default scopes can cause issues in some scenarios.
#
# Usage:
#   class Patient < ApplicationRecord
#     include OrganizationScoped
#   end
#
# This will:
# - Add belongs_to :organization
# - Add validation for organization presence
# - Add default_scope based on Current.organization (when set)
# - Provide helper scopes for organization filtering
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

    # ===========================================================================
    # Default Scope (USE WITH CAUTION)
    # ===========================================================================
    # This default scope automatically filters records by the current organization
    # when Current.organization is set. This prevents accidental data leaks.
    #
    # IMPORTANT: This can cause issues in:
    # - Background jobs (where Current.organization isn't set)
    # - Admin interfaces (where you need to see all records)
    # - Tests (where you need explicit control)
    #
    # Use `unscoped` to bypass: Patient.unscoped.all
    # ===========================================================================
    default_scope do
      if Current.respond_to?(:organization) && Current.organization.present?
        where(organization: Current.organization)
      else
        all
      end
    end

    # ===========================================================================
    # Scopes
    # ===========================================================================
    scope :for_organization, ->(org) { unscoped.where(organization: org) }
    scope :global, -> { unscoped }

    # ===========================================================================
    # Callbacks
    # ===========================================================================
    # Automatically set organization from Current if not already set
    before_validation :set_organization_from_current, on: :create

    private

    def set_organization_from_current
      return if organization_id.present?
      return unless Current.respond_to?(:organization)

      self.organization = Current.organization
    end
  end

  # ===========================================================================
  # Class Methods
  # ===========================================================================
  class_methods do
    # Find a record by ID, but only within the specified organization
    # Raises ActiveRecord::RecordNotFound if not found or wrong org
    def find_in_organization(id, organization)
      unscoped.where(organization: organization).find(id)
    end

    # Check if a record exists in the given organization
    def exists_in_organization?(id, organization)
      unscoped.where(organization: organization, id: id).exists?
    end

    # Count records for a specific organization
    def count_for_organization(organization)
      unscoped.where(organization: organization).count
    end
  end
end
