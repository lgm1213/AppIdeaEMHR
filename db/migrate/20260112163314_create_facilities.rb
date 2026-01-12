class CreateFacilities < ActiveRecord::Migration[8.1]
  def change
    create_table :facilities, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :phone
      t.text :address

      t.timestamps
    end
  end
end
