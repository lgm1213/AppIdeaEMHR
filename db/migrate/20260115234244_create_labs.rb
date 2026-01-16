class CreateLabs < ActiveRecord::Migration[8.1]
  def change
    create_table :labs, id: :uuid do |t|
      t.references :patient, null: false, foreign_key: true, type: :uuid
      t.string :test_type
      t.string :result
      t.string :status
      t.date :date

      t.timestamps
    end
  end
end
