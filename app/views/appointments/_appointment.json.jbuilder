json.extract! appointment, :id, :patient_id, :provider_id, :organization_id, :start_time, :end_time, :status, :reason, :created_at, :updated_at
json.url appointment_url(appointment, format: :json)
