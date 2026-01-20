class AddModifiersToProcedures < ActiveRecord::Migration[8.1]
  def change
    add_column :procedures, :modifiers, :string
  end
end
