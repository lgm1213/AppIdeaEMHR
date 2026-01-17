class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid

      # Custom References for User-to-User messaging
      t.references :sender, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :recipient, null: false, foreign_key: { to_table: :users }, type: :uuid

      t.references :patient, null: true, foreign_key: true, type: :uuid # Optional (General msgs don't need a patient)

      t.string :category, default: "General"
      t.string :subject
      t.text :body
      t.datetime :read_at

      t.timestamps
    end
  end
end
