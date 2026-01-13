class CreateEncounters < ActiveRecord::Migration[8.1]
  def change
    create_table :encounters, id: :uuid do |t|
      t.references :patient, null: false, foreign_key: true, type: :uuid
      t.references :provider, null: false, foreign_key: true, type: :uuid
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.datetime :visit_date
      t.text :subjective
      t.text :objective
      t.text :assessment
      t.text :plan

      t.timestamps
    end
  end
end
