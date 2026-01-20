class CreateCptCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :cpt_codes, id: :uuid do |t|
      t.string :code
      t.text :description

      t.timestamps
    end
  end
end
