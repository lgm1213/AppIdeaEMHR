class CreateConditions < ActiveRecord::Migration[8.1]
  def change
    create_table :conditions, id: :uuid do |t|
      t.references :patient, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :icd10_code
      t.string :status
      t.date :onset_date

      t.timestamps
    end
  end
end
