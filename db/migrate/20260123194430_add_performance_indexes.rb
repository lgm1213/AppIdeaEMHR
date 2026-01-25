class AddPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    # Patient lookups by name within an organization (common search pattern)
    add_index :patients, [ :organization_id, :last_name, :first_name ],
              name: "index_patients_on_org_and_name"

    # Encounter history queries (ordered by visit date)
    add_index :encounters, [ :patient_id, :visit_date ],
              name: "index_encounters_on_patient_and_visit_date"

    # Provider schedule lookups
    add_index :appointments, [ :provider_id, :start_time ],
              name: "index_appointments_on_provider_and_start_time"

    # Organization-scoped appointment queries
    add_index :appointments, [ :organization_id, :start_time ],
              name: "index_appointments_on_org_and_start_time"

    # Patient appointment history
    add_index :appointments, [ :patient_id, :start_time ],
              name: "index_appointments_on_patient_and_start_time"

    # Status-based appointment filtering (e.g., "show all scheduled")
    add_index :appointments, [ :organization_id, :status ],
              name: "index_appointments_on_org_and_status"

    # Unread messages count optimization
    add_index :messages, [ :recipient_id, :read_at ],
              name: "index_messages_on_recipient_and_read_at"

    # Document lookups by patient
    unless index_exists?(:documents, :patient_id)
      add_index :documents, :patient_id
    end

    # Medication lookups by patient
    unless index_exists?(:medications, :patient_id)
      add_index :medications, :patient_id
    end

    # Lab results by patient
    unless index_exists?(:labs, :patient_id)
      add_index :labs, :patient_id
    end

    # Conditions/Diagnoses by patient
    unless index_exists?(:conditions, :patient_id)
      add_index :conditions, :patient_id
    end
  end
end
