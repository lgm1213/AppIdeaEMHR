class AddIpAddressToVersions < ActiveRecord::Migration[8.1]
  def change
    add_column :versions, :ip_address, :string
  end
end
