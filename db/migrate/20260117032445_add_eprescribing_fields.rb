class AddEprescribingFields < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :street_address, :string
    add_column :patients, :city, :string
    add_column :patients, :state, :string
    add_column :patients, :zip_code, :string


    add_column :medications, :sig, :text             # e.g., "Take 1 tablet by mouth daily"
    add_column :medications, :quantity, :integer     # e.g., 30
    add_column :medications, :quantity_unit, :string # e.g., "Tablets"
    add_column :medications, :refills, :integer, default: 0
    add_column :medications, :days_supply, :integer
    add_column :medications, :pharmacy_note, :string
  end
end
