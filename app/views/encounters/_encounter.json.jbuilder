json.extract! encounter, :id, :patient_id, :provider_id, :organization_id, :visit_date, :subjective, :objective, :assessment, :plan, :created_at, :updated_at
json.url encounter_url(encounter, format: :json)
