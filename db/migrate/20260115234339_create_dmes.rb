class CreateDmes < ActiveRecord::Migration[8.1]
  def change
    create_table :dmes, id: :uuid do |t|
      t.references :patient, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :status
      t.date :prescribed_date

      t.timestamps
    end
  end
end
