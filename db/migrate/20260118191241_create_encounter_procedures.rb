class CreateEncounterProcedures < ActiveRecord::Migration[8.1]
  def change
    create_table :encounter_procedures, id: :uuid do |t|
      t.references :encounter, null: false, foreign_key: true, type: :uuid
      t.references :procedure, null: false, foreign_key: true, type: :uuid
      t.decimal :charge_amount, precision: 10, scale: 2

      t.timestamps
    end
  end
end
