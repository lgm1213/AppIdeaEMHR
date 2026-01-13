json.extract! patient, :id, :first_name, :last_name, :date_of_birth, :gender, :phone, :email, :organization_id, :created_at, :updated_at
json.url patient_url(patient, format: :json)
