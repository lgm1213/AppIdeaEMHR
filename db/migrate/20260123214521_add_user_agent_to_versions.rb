class AddUserAgentToVersions < ActiveRecord::Migration[8.1]
  def change
    add_column :versions, :user_agent, :string
  end
end
