class CreateVitals < ActiveRecord::Migration[8.1]
  def change
    create_table :vitals, id: :uuid do |t|
      t.references :encounter, null: false, foreign_key: true, type: :uuid
      t.decimal :height_inches
      t.decimal :weight_lbs
      t.decimal :temp_f
      t.integer :bp_systolic
      t.integer :bp_diastolic
      t.integer :heart_rate
      t.integer :resp_rate
      t.integer :o2_sat
      t.decimal :bmi

      t.timestamps
    end
  end
end
