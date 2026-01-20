class AddOrganizationToProcedures < ActiveRecord::Migration[8.1]
  def change
    add_reference :procedures, :organization, null: true, foreign_key: true, type: :uuid
    first_org_id = Organization.first&.id

    if first_org_id
      Procedure.update_all(organization_id: first_org_id)
    else
      say "No organizations found. Deleting orphan procedures to ensure schema validity."
      Procedure.delete_all
    end

    change_column_null :procedures, :organization_id, false

    remove_index :procedures, :code if index_exists?(:procedures, :code)

    add_index :procedures, [ :organization_id, :code ], unique: true
  end
end
