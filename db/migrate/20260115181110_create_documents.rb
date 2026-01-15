class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :documents, id: :uuid do |t|
      t.references :patient, null: false, foreign_key: true, type: :uuid
      t.references :uploader, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.datetime :last_accessed_at
      t.timestamps
    end
  end
end
