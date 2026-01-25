class AddOrganizationIdToVersions < ActiveRecord::Migration[8.1]
  def change
    add_column :versions, :organization_id, :uuid
    add_index :versions, :organization_id
  end
end
