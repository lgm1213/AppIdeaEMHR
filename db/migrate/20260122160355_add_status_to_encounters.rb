class AddStatusToEncounters < ActiveRecord::Migration[8.1]
  def change
    add_column :encounters, :status, :integer, default: 0, null: false
  end
end
