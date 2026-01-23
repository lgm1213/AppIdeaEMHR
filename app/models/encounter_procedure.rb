class EncounterProcedure < ApplicationRecord
  belongs_to :encounter
  belongs_to :procedure

  # Virtual attribute to capture raw input from the form
  attr_accessor :cpt_code_search_value

  validates :procedure, presence: { message: "could not be found from the code provided" }
  validates :charge_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :resolve_procedure_from_search_value

  private

  def resolve_procedure_from_search_value
    # Skips if nothing was typed (avoids errors on empty rows)
    return if cpt_code_search_value.blank?

    # Parse "99213 - Office Visit" -> "99213"
    clean_code = cpt_code_search_value.split(" - ").first.strip

    # Finds the procedure within the organization
    if encounter&.organization_id
      found_procedure = Procedure.find_by(organization_id: encounter.organization_id, code: clean_code)

      if found_procedure
        self.procedure = found_procedure
        self.charge_amount ||= found_procedure.price
      end
    end
  end
end
