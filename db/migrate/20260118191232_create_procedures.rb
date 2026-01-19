class CreateProcedures < ActiveRecord::Migration[8.1]
  def change
    create_table :procedures, id: :uuid do |t|
      t.string :code
      t.string :name
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end
    add_index :procedures, :code, unique: true
  end
end
