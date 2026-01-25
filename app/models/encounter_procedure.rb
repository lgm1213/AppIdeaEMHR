class EncounterProcedure < ApplicationRecord
  belongs_to :encounter, inverse_of: :encounter_procedures
  belongs_to :procedure, inverse_of: :encounter_procedures

  # Virtual attribute for the form to "talk" to
  attr_accessor :cpt_code_search_value

  # ===========================================================================
  # Validations
  # ===========================================================================
  validates :procedure, presence: { message: "must be selected or entered" }
  validates :charge_amount,
            numericality: { greater_than_or_equal_to: 0, message: "must be a positive amount" },
            allow_nil: true

  # Ensure we don't add the same procedure twice to an encounter
  validates :procedure_id, uniqueness: {
    scope: :encounter_id,
    message: "has already been added to this encounter"
  }

  # ===========================================================================
  # Callbacks
  # ===========================================================================
  before_validation :resolve_procedure_from_search_value
  after_initialize :set_default_values, if: :new_record?

  # ===========================================================================
  # Scopes
  # ===========================================================================
  scope :with_charges, -> { where.not(charge_amount: [ nil, 0 ]) }
  scope :by_code, -> { joins(:procedure).order("procedures.code") }

  # ===========================================================================
  # Instance Methods
  # ===========================================================================
  def total_charge
    # Was (charge * units), but units column doesn't exist
    charge_amount || 0
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
    # Removed self.units assignment
    self.charge_amount ||= procedure&.price || 0.0
  end

  def resolve_procedure_from_search_value
    # Skip if no search value provided
    return if cpt_code_search_value.blank?

    # If a procedure is already linked (e.g. edit mode), don't overwrite unless changed
    return if procedure_id.present? && !cpt_code_search_value_changed?

    # Ensure we have an encounter to get the organization from
    unless encounter&.organization_id
      errors.add(:base, "Cannot resolve procedure without an organization context")
      return
    end

    org_id = encounter.organization_id

    # 1. CLEAN THE INPUT: "99213 - Office Visit" -> "99213"
    clean_code = cpt_code_search_value.split(" - ").first.strip

    # 2. Look up Master Data (for description fallback)
    master_cpt = CptCode.find_by(code: clean_code)

    # 3. Find or Create the Practice-Specific Procedure
    begin
      self.procedure = Procedure.find_or_create_by!(
        organization_id: org_id,
        code: clean_code
      ) do |new_proc|
        # Defaults for new procedure creation
        new_proc.name = master_cpt&.description || "Custom Procedure #{clean_code}"
        new_proc.price = 0.00

        Rails.logger.info("[EncounterProcedure] Auto-created Procedure: #{clean_code} for Org #{org_id}")
      end

      # 4. Set charge amount from the procedure's price if not manually set
      self.charge_amount ||= procedure.price

    rescue ActiveRecord::RecordInvalid => e
      errors.add(:procedure, "could not be created: #{e.message}")
    end
  end

  # Helper to detect if the search value is actually different from current procedure
  def cpt_code_search_value_changed?
    return true if procedure.nil?
    !cpt_code_search_value.include?(procedure.code)
  end
end
