class AddAppointmentToEncounters < ActiveRecord::Migration[8.1]
  def change
    add_reference :encounters, :appointment, null: true, foreign_key: true, type: :uuid
  end
end
