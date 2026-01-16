class CreateCareTeamMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :care_team_members, id: :uuid do |t|
      t.references :patient, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :role
      t.string :status

      t.timestamps
    end
  end
end
