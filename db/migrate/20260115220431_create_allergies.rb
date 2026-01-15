class CreateAllergies < ActiveRecord::Migration[8.1]
  def change
    create_table :allergies, id: :uuid do |t|
      t.references :patient, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :reaction
      t.string :severity
      t.string :status

      t.timestamps
    end
  end
end
