class FixEncounterSchema < ActiveRecord::Migration[8.1]
  def change
    add_column :encounter_procedures, :modifiers, :string


    create_table :icd_codes, id: :uuid do |t|
      t.string :code, index: true
      t.text :description
      t.timestamps
    end

    create_table :encounter_diagnoses, id: :uuid do |t|
      t.references :encounter, null: false, foreign_key: true, type: :uuid

      t.string :icd_code
      t.string :description

      t.timestamps
    end
  end
end
