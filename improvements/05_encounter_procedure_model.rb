# frozen_string_literal: true

# ==============================================================================
# IMPROVEMENT #5: EncounterProcedure Model with Proper Validations
# ==============================================================================
# File: app/models/encounter_procedure.rb
#
# Changes:
# - Added validation for procedure presence
# - Added validation for charge_amount
# - Added units validation
# - Improved error handling in resolve_procedure_from_code
# - Added logging for procedure creation
# ==============================================================================

class EncounterProcedure < ApplicationRecord
  belongs_to :encounter, inverse_of: :encounter_procedures
  belongs_to :procedure, inverse_of: :encounter_procedures

  # Virtual attributes for the form to "talk" to
  attr_accessor :cpt_code_search_value

  # ===========================================================================
  # Validations
  # ===========================================================================
  validates :procedure, presence: { message: "must be selected or entered" }
  validates :charge_amount,
            numericality: { greater_than_or_equal_to: 0, message: "must be a positive amount" },
            allow_nil: true
  validates :units,
            numericality: { only_integer: true, greater_than: 0, message: "must be at least 1" },
            allow_nil: true

  # Ensure we don't add the same procedure twice to an encounter
  validates :procedure_id, uniqueness: {
    scope: :encounter_id,
    message: "has already been added to this encounter"
  }

  # ===========================================================================
  # Callbacks
  # ===========================================================================
  before_validation :resolve_procedure_from_code
  before_validation :set_default_values

  # ===========================================================================
  # Scopes
  # ===========================================================================
  scope :with_charges, -> { where.not(charge_amount: [ nil, 0 ]) }
  scope :by_code, -> { joins(:procedure).order("procedures.code") }

  # ===========================================================================
  # Instance Methods
  # ===========================================================================
  def total_charge
    return 0 unless charge_amount && units
    charge_amount * units
  end

  def display_name
    return "Unknown Procedure" unless procedure
    "#{procedure.code} - #{procedure.name}"
  end

  def modifiers_array
    return [] if modifiers.blank?
    modifiers.split(",").map(&:strip).reject(&:blank?)
  end

  def modifiers_display
    arr = modifiers_array
    arr.any? ? arr.join(", ") : "None"
  end

  private

  def set_default_values
    self.units ||= 1
    self.charge_amount ||= procedure&.price || 0
  end

  def resolve_procedure_from_code
    # Skip if no search value provided or procedure already set
    return if cpt_code_search_value.blank?
    return if procedure_id.present? && !procedure_id_changed?

    # Ensure we have an encounter to get the organization from
    unless encounter&.organization_id
      errors.add(:base, "Cannot resolve procedure without an organization context")
      return
    end

    org_id = encounter.organization_id

    # Step A: Find the Master CPT data (for description)
    master_cpt = CptCode.find_by(code: cpt_code_search_value.strip)

    # Step B: Find or Create the Practice-Specific Procedure
    begin
      self.procedure = Procedure.find_or_create_by!(
        organization_id: org_id,
        code: cpt_code_search_value.strip
      ) do |new_proc|
        # If we are creating it for the first time, set defaults:
        new_proc.name = master_cpt&.description || "Custom Procedure #{cpt_code_search_value}"
        new_proc.price = 0.00 # Practice can update price later

        # Log the creation for auditing
        Rails.logger.info(
          "[EncounterProcedure] Auto-created Procedure: " \
          "code=#{new_proc.code}, org_id=#{org_id}, name=#{new_proc.name}"
        )
      end

      # Set charge amount from the procedure's default price if not already set
      self.charge_amount ||= procedure.price

    rescue ActiveRecord::RecordInvalid => e
      errors.add(:procedure, "could not be created: #{e.message}")
      Rails.logger.error("[EncounterProcedure] Failed to create procedure: #{e.message}")
    end
  end
end
