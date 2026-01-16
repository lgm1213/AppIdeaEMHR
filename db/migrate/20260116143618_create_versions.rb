class CreateVersions < ActiveRecord::Migration[8.1]
  # This is PaperTrail's initial migration edited to use UUIDs and add a patient reference.
  # The largest text column available in all supported RDBMS.
  TEXT_BYTES = 1_073_741_823

  def change
    create_table :versions, id: :uuid do |t|
      # Custom Column for Patient tracking
      t.uuid     :patient_id
      t.datetime :created_at

      # Changed bigint to uuid for item_id
      t.uuid     :item_id,   null: false

      t.string   :item_type, null: false
      t.string   :event,     null: false
      t.string   :whodunnit
      t.text     :object, limit: TEXT_BYTES
      t.text     :object_changes, limit: TEXT_BYTES
    end

    add_index :versions, %i[item_type item_id]
    add_index :versions, :patient_id
  end
end
