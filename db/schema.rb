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

ActiveRecord::Schema[8.1].define(version: 2026_01_13_205242) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "facilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "address"
    t.datetime "created_at", null: false
    t.string "name"
    t.uuid "organization_id", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_facilities_on_organization_id"
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
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "email"
    t.string "first_name"
    t.string "gender"
    t.string "last_name"
    t.uuid "organization_id", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_patients_on_organization_id"
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

  add_foreign_key "facilities", "organizations"
  add_foreign_key "patients", "organizations"
  add_foreign_key "providers", "organizations"
  add_foreign_key "providers", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "organizations"
end
