class CreateProviders < ActiveRecord::Migration[8.1]
  def change
    create_table :providers, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :npi
      t.string :license_number
      t.string :dea_number
      t.string :specialty
      t.string :taxonomy_code

      t.timestamps
    end
  end
end
