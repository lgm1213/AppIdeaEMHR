class EncounterProcedure < ApplicationRecord
  belongs_to :encounter
  belongs_to :procedure # The practice-specific record

  # Virtual attributes for the form to "talk" to
  attr_accessor :cpt_code_search_value

  # Before validation, find or create the Procedure record
  before_validation :resolve_procedure_from_code

  private

  def resolve_procedure_from_code
    # If the user selected a code from the search bar (e.g. "99213")
    if cpt_code_search_value.present?

      # Step A: Find the Master CPT data (for description)
      master_cpt = CptCode.find_by(code: cpt_code_search_value)

      # Step B: Find or Create the Practice-Specific Procedure
      # We use the organization from the parent encounter
      org_id = encounter.organization_id

      self.procedure = Procedure.find_or_create_by!(
        organization_id: org_id,
        code: cpt_code_search_value
      ) do |new_proc|
        # If we are creating it for the first time, set defaults:
        new_proc.name = master_cpt&.description || "Custom Procedure"
        new_proc.price = 0.00 # Practice can update price later
      end
    end
  end
end
