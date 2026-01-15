class CreateMedications < ActiveRecord::Migration[8.1]
  def change
    create_table :medications, id: :uuid do |t|
      t.references :patient, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :dosage
      t.string :frequency
      t.string :status
      t.references :prescribed_by, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.timestamps
    end
  end
end
