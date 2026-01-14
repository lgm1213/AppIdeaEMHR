class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments, id: :uuid do |t|
      t.references :patient, null: false, foreign_key: true, type: :uuid
      t.references :provider, null: false, foreign_key: true, type: :uuid
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.datetime :start_time
      t.datetime :end_time
      t.integer :status
      t.text :reason

      t.timestamps
    end
  end
end
