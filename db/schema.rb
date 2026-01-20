# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_20_175330) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "allergies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.uuid "patient_id", null: false
    t.string "reaction"
    t.string "severity"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_allergies_on_patient_id"
  end

  create_table "appointments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "end_time"
    t.uuid "organization_id", null: false
    t.uuid "patient_id", null: false
    t.uuid "provider_id", null: false
    t.text "reason"
    t.datetime "start_time"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_appointments_on_organization_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["provider_id"], name: "index_appointments_on_provider_id"
  end

  create_table "care_team_members", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "patient_id", null: false
    t.string "role"
    t.string "status"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["patient_id"], name: "index_care_team_members_on_patient_id"
    t.index ["user_id"], name: "index_care_team_members_on_user_id"
  end

  create_table "conditions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code"
    t.string "code_system", default: "ICD-10"
    t.datetime "created_at", null: false
    t.string "name"
    t.date "onset_date"
    t.uuid "patient_id", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_conditions_on_patient_id"
  end

  create_table "cpt_codes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "updated_at", null: false
  end

  create_table "dmes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.uuid "patient_id", null: false
    t.date "prescribed_date"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_dmes_on_patient_id"
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_accessed_at"
    t.uuid "patient_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "uploader_id", null: false
    t.index ["patient_id"], name: "index_documents_on_patient_id"
    t.index ["uploader_id"], name: "index_documents_on_uploader_id"
  end

  create_table "encounter_procedures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "charge_amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.uuid "encounter_id", null: false
    t.uuid "procedure_id", null: false
    t.datetime "updated_at", null: false
    t.index ["encounter_id"], name: "index_encounter_procedures_on_encounter_id"
    t.index ["procedure_id"], name: "index_encounter_procedures_on_procedure_id"
  end

  create_table "encounters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "appointment_id"
    t.text "assessment"
    t.datetime "created_at", null: false
    t.text "objective"
    t.uuid "organization_id", null: false
    t.uuid "patient_id", null: false
    t.text "plan"
    t.uuid "provider_id", null: false
    t.text "subjective"
    t.datetime "updated_at", null: false
    t.datetime "visit_date"
    t.index ["appointment_id"], name: "index_encounters_on_appointment_id"
    t.index ["organization_id"], name: "index_encounters_on_organization_id"
    t.index ["patient_id"], name: "index_encounters_on_patient_id"
    t.index ["provider_id"], name: "index_encounters_on_provider_id"
  end

  create_table "facilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "address"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "name"
    t.uuid "organization_id", null: false
    t.string "phone"
    t.string "state"
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["organization_id"], name: "index_facilities_on_organization_id"
  end

  create_table "labs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.uuid "patient_id", null: false
    t.string "result"
    t.string "status"
    t.string "test_type"
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_labs_on_patient_id"
  end

  create_table "medications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "days_supply"
    t.string "dosage"
    t.string "frequency"
    t.string "name"
    t.uuid "patient_id", null: false
    t.string "pharmacy_note"
    t.uuid "prescribed_by_id", null: false
    t.integer "quantity"
    t.string "quantity_unit"
    t.integer "refills", default: 0
    t.text "sig"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_medications_on_patient_id"
    t.index ["prescribed_by_id"], name: "index_medications_on_prescribed_by_id"
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "body"
    t.string "category", default: "General"
    t.datetime "created_at", null: false
    t.uuid "organization_id", null: false
    t.uuid "patient_id"
    t.datetime "read_at"
    t.uuid "recipient_id", null: false
    t.uuid "sender_id", null: false
    t.string "subject"
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_messages_on_organization_id"
    t.index ["patient_id"], name: "index_messages_on_patient_id"
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "plan"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug"
  end

  create_table "patients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "city"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "email"
    t.string "first_name"
    t.string "gender"
    t.string "last_name"
    t.uuid "organization_id", null: false
    t.string "phone"
    t.string "state"
    t.string "street_address"
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["organization_id"], name: "index_patients_on_organization_id"
  end

  create_table "procedures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "modifiers"
    t.string "name"
    t.uuid "organization_id", null: false
    t.decimal "price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["organization_id", "code"], name: "index_procedures_on_organization_id_and_code", unique: true
    t.index ["organization_id"], name: "index_procedures_on_organization_id"
  end

  create_table "providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "dea_number"
    t.string "license_number"
    t.string "npi"
    t.uuid "organization_id", null: false
    t.string "specialty"
    t.string "taxonomy_code"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["organization_id"], name: "index_providers_on_organization_id"
    t.index ["user_id"], name: "index_providers_on_user_id"
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "first_name"
    t.string "last_name"
    t.uuid "organization_id", null: false
    t.string "password_digest", null: false
    t.integer "role"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  create_table "versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at"
    t.string "event", null: false
    t.uuid "item_id", null: false
    t.string "item_type", null: false
    t.text "object"
    t.text "object_changes"
    t.uuid "patient_id"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["patient_id"], name: "index_versions_on_patient_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "allergies", "patients"
  add_foreign_key "appointments", "organizations"
  add_foreign_key "appointments", "patients"
  add_foreign_key "appointments", "providers"
  add_foreign_key "care_team_members", "patients"
  add_foreign_key "care_team_members", "users"
  add_foreign_key "conditions", "patients"
  add_foreign_key "dmes", "patients"
  add_foreign_key "documents", "patients"
  add_foreign_key "documents", "users", column: "uploader_id"
  add_foreign_key "encounter_procedures", "encounters"
  add_foreign_key "encounter_procedures", "procedures"
  add_foreign_key "encounters", "appointments"
  add_foreign_key "encounters", "organizations"
  add_foreign_key "encounters", "patients"
  add_foreign_key "encounters", "providers"
  add_foreign_key "facilities", "organizations"
  add_foreign_key "labs", "patients"
  add_foreign_key "medications", "patients"
  add_foreign_key "medications", "users", column: "prescribed_by_id"
  add_foreign_key "messages", "organizations"
  add_foreign_key "messages", "patients"
  add_foreign_key "messages", "users", column: "recipient_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "patients", "organizations"
  add_foreign_key "procedures", "organizations"
  add_foreign_key "providers", "organizations"
  add_foreign_key "providers", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "organizations"
end
