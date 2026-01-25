class CreateIcdCodes < ActiveRecord::Migration[8.1]
  def change
    # Only create the table if it doesn't exist yet
    unless table_exists?(:icd_codes)
      create_table :icd_codes, id: :uuid do |t|
        t.string :code
        t.string :description

        t.timestamps
      end

      add_index :icd_codes, :code
    end
  end
end
