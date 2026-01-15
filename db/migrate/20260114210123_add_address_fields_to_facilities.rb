class AddAddressFieldsToFacilities < ActiveRecord::Migration[8.1]
  def change
    add_column :facilities, :city, :string
    add_column :facilities, :state, :string
    add_column :facilities, :zip_code, :string
  end
end
