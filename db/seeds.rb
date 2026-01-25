# frozen_string_literal: true

# ==============================================================================
# IMPROVEMENT #7: Idempotent Seeds File
# ==============================================================================
# File: db/seeds.rb
#
# Changes:
# - Uses find_or_create_by! for all records
# - Can be run multiple times without errors
# - Organized into logical sections
# - Added progress output
# - Added development-only seed data section
# ==============================================================================

# ===========================================================================
# Helper Methods
# ===========================================================================
def seed_section(name)
  puts "\n#{"=" * 60}"
  puts "Seeding: #{name}"
  puts "=" * 60
  yield
  puts "✓ #{name} complete"
end

def seed_record(model, find_attrs, additional_attrs = {})
  record = model.find_or_create_by!(find_attrs) do |r|
    additional_attrs.each { |key, value| r.send("#{key}=", value) }
  end
  puts "  → #{model.name}: #{find_attrs.values.first}"
  record
end

# ===========================================================================
# CPT Codes (Master Reference Data)
# ===========================================================================
seed_section "CPT Codes" do
  cpt_codes = [
    # Evaluation & Management - Office Visits
    { code: "99201", description: "Office/outpatient visit, new patient, minimal" },
    { code: "99202", description: "Office/outpatient visit, new patient, straightforward" },
    { code: "99203", description: "Office/outpatient visit, new patient, low complexity" },
    { code: "99204", description: "Office/outpatient visit, new patient, moderate complexity" },
    { code: "99205", description: "Office/outpatient visit, new patient, high complexity" },
    { code: "99211", description: "Office/outpatient visit, established patient, minimal" },
    { code: "99212", description: "Office/outpatient visit, established patient, straightforward" },
    { code: "99213", description: "Office/outpatient visit, established patient, low complexity" },
    { code: "99214", description: "Office/outpatient visit, established patient, moderate complexity" },
    { code: "99215", description: "Office/outpatient visit, established patient, high complexity" },

    # Preventive Medicine
    { code: "99381", description: "Preventive visit, new patient, infant (age <1)" },
    { code: "99382", description: "Preventive visit, new patient, early childhood (1-4)" },
    { code: "99383", description: "Preventive visit, new patient, late childhood (5-11)" },
    { code: "99384", description: "Preventive visit, new patient, adolescent (12-17)" },
    { code: "99385", description: "Preventive visit, new patient, adult (18-39)" },
    { code: "99386", description: "Preventive visit, new patient, adult (40-64)" },
    { code: "99387", description: "Preventive visit, new patient, adult (65+)" },
    { code: "99391", description: "Preventive visit, established patient, infant (age <1)" },
    { code: "99392", description: "Preventive visit, established patient, early childhood (1-4)" },
    { code: "99393", description: "Preventive visit, established patient, late childhood (5-11)" },
    { code: "99394", description: "Preventive visit, established patient, adolescent (12-17)" },
    { code: "99395", description: "Preventive visit, established patient, adult (18-39)" },
    { code: "99396", description: "Preventive visit, established patient, adult (40-64)" },
    { code: "99397", description: "Preventive visit, established patient, adult (65+)" },

    # Common Procedures
    { code: "36415", description: "Venipuncture (blood draw)" },
    { code: "81002", description: "Urinalysis, non-automated, without microscopy" },
    { code: "87880", description: "Rapid strep test" },
    { code: "90715", description: "Tdap vaccine" },
    { code: "90471", description: "Immunization administration" },
    { code: "96372", description: "Therapeutic injection, subcutaneous or intramuscular" },

    # Radiology
    { code: "71046", description: "Chest X-ray, 2 views" },
    { code: "73030", description: "X-ray exam of shoulder" },
    { code: "73070", description: "X-ray exam of elbow" },
    { code: "73110", description: "X-ray exam of wrist" },
    { code: "73560", description: "X-ray exam of knee, 1-2 views" },
    { code: "73600", description: "X-ray exam of ankle" }
  ]

  cpt_codes.each do |attrs|
    seed_record(CptCode, { code: attrs[:code] }, { description: attrs[:description] })
  end
end

# ===========================================================================
# ICD-10 Codes (Master Reference Data) - Optional
# ===========================================================================
seed_section "ICD Codes" do
  icd_codes = [
    { code: "J06.9", description: "Acute upper respiratory infection, unspecified" },
    { code: "J20.9", description: "Acute bronchitis, unspecified" },
    { code: "J02.9", description: "Acute pharyngitis, unspecified" },
    { code: "J00", description: "Acute nasopharyngitis (common cold)" },
    { code: "I10", description: "Essential (primary) hypertension" },
    { code: "E11.9", description: "Type 2 diabetes mellitus without complications" },
    { code: "M54.5", description: "Low back pain" },
    { code: "R05.9", description: "Cough, unspecified" },
    { code: "R50.9", description: "Fever, unspecified" },
    { code: "Z00.00", description: "General adult medical examination without abnormal findings" }
  ]

  icd_codes.each do |attrs|
    seed_record(IcdCode, { code: attrs[:code] }, { description: attrs[:description] })
  end
end

# ===========================================================================
# Development & Demo Data (Only in development/test)
# ===========================================================================
if Rails.env.development? || Rails.env.test?
  seed_section "Demo Organization" do
    # Create a demo organization
    @demo_org = Organization.find_or_create_by!(name: "Demo Family Practice") do |org|
      org.slug = "demo-family-practice"
    end
    puts "  → Organization: #{@demo_org.name} (slug: #{@demo_org.slug})"

    # Create demo facility
    Facility.find_or_create_by!(organization: @demo_org, name: "Main Office") do |f|
      f.address = "123 Medical Center Drive"
      f.city = "Miami"
      f.state = "FL"
      f.zip_code = "33101"
      f.phone = "305-555-0100"
    end
    puts "  → Facility: Main Office"
  end

  seed_section "Demo Users" do
    # Admin user
    @admin = User.find_or_create_by!(email_address: "admin@demo.com") do |u|
      u.first_name = "Admin"
      u.last_name = "User"
      u.password = "password"
      u.password_confirmation = "password"
      u.role = :admin
      u.organization = @demo_org
    end
    puts "  → Admin: admin@example.com / password"

    # Provider user with credentials
    @provider_user = User.find_or_create_by!(email_address: "doctor@example.com") do |u|
      u.first_name = "Jane"
      u.last_name = "Smith"
      u.password = "password"
      u.password_confirmation = "password"
      u.role = :provider
      u.organization = @demo_org
    end

    @provider_record = Provider.find_or_create_by!(user: @provider_user) do |p|
      p.organization = @demo_org
      p.npi = "1234567890"
      p.license_number = "FL-MD-12345"
      p.specialty = "Family Medicine"
      p.taxonomy_code = "207Q00000X"
    end
    puts "  → Provider: doctor@example.com / password (Dr. Jane Smith)"

    # Staff user
    User.find_or_create_by!(email_address: "staff@example.com") do |u|
      u.first_name = "Staff"
      u.last_name = "Member"
      u.password = "password"
      u.password_confirmation = "password"
      u.role = :staff
      u.organization = @demo_org
    end
    puts "  → Staff: staff@example.com / password"

    # Superadmin (no organization)
    User.find_or_create_by!(email_address: "superadmin@example.com") do |u|
      u.first_name = "Super"
      u.last_name = "Admin"
      u.password = "password"
      u.password_confirmation = "password"
      u.role = :superadmin
      u.organization = @demo_org
    end
    puts "  → Superadmin: superadmin@example.com / password"
  end

  seed_section "Demo Patients" do
    patients_data = [
      { first_name: "John", last_name: "Doe", dob: "1985-03-15", gender: "Male" },
      { first_name: "Jane", last_name: "Doe", dob: "1988-07-22", gender: "Female" },
      { first_name: "Robert", last_name: "Johnson", dob: "1970-11-08", gender: "Male" }
    ]

    patients_data.each do |data|
      Patient.find_or_create_by!(
        organization: @demo_org,
        first_name: data[:first_name],
        last_name: data[:last_name]
      ) do |p|
        p.date_of_birth = Date.parse(data[:dob])
        p.gender = data[:gender]
        p.email = "#{data[:first_name].downcase}.#{data[:last_name].downcase}@example.com"
        p.phone = "305-555-#{rand(1000..9999)}"
        p.street_address = "#{rand(100..999)} #{%w[Oak Elm Pine Maple].sample} Street"
        p.city = "Miami"
        p.state = "FL"
        p.zip_code = "331#{rand(10..99)}"
      end
      puts "  → Patient: #{data[:first_name]} #{data[:last_name]}"
    end
  end

  seed_section "Demo Procedures (Practice Fee Schedule)" do
    procedures = [
      { code: "99213", name: "Office Visit - Established (Low)", price: 95.00 },
      { code: "99214", name: "Office Visit - Established (Moderate)", price: 145.00 },
      { code: "99203", name: "Office Visit - New (Low)", price: 150.00 },
      { code: "36415", name: "Blood Draw", price: 25.00 },
      { code: "90715", name: "Tdap Vaccine", price: 75.00 }
    ]

    procedures.each do |data|
      Procedure.find_or_create_by!(organization: @demo_org, code: data[:code]) do |p|
        p.name = data[:name]
        p.price = data[:price]
      end
      puts "  → Procedure: #{data[:code]} - $#{data[:price]}"
    end
  end

  # ===========================================================================
  # NEW: Clinical Encounters & Vitals
  # ===========================================================================
  seed_section "Demo Encounters" do
    john = Patient.find_by(organization: @demo_org, first_name: "John", last_name: "Doe")
    jane = Patient.find_by(organization: @demo_org, first_name: "Jane", last_name: "Doe")
    proc_visit = Procedure.find_by(organization: @demo_org, code: "99213")
    proc_draw = Procedure.find_by(organization: @demo_org, code: "36415")

    # 1. Finalized Encounter (John Doe) - To test Review Page & Vitals
    e1 = Encounter.find_or_create_by!(
      organization: @demo_org,
      patient: john,
      visit_date: 2.days.ago.to_date,
      provider: @provider_record
    ) do |e|
      # Status: 2 (completed) or :finalized depending on your enum
      e.status = 2
      e.subjective = "Patient presents with persistent cough for 3 days. No fever. Reports mild fatigue."
      e.objective = "Lungs clear to auscultation bilaterally. Pharynx slightly erythematous. No exudates."
    end

    # Add Vitals (Check if exists first to be idempotent)
    unless e1.vital
      e1.create_vital!(
        height_inches: 70, weight_lbs: 185, bmi: 26.5,
        temp_f: 98.6, bp_systolic: 124, bp_diastolic: 82,
        heart_rate: 72, resp_rate: 16, o2_sat: 99
      )
    end

    # Add Procedures
    e1.encounter_procedures.find_or_create_by!(procedure: proc_visit) { |ep| ep.charge_amount = proc_visit.price }
    puts "  → Encounter: Finalized visit for John Doe (with Vitals)"


    # 2. Draft Encounter (Jane Doe) - To test "Continue Editing"
    e2 = Encounter.find_or_create_by!(
      organization: @demo_org,
      patient: jane,
      visit_date: Date.today,
      provider: @provider_record
    ) do |e|
      e.status = 0 # Draft
      e.subjective = "Follow up on hypertension. Patient states BP has been stable at home."
    end
    puts "  → Encounter: Draft visit for Jane Doe"
  end
end

# ===========================================================================
# Summary
# ===========================================================================
puts "\n#{"=" * 60}"
puts "SEED COMPLETE"
puts "=" * 60
puts "CPT Codes: #{CptCode.count}"
puts "ICD Codes: #{defined?(IcdCode) ? IcdCode.count : 'N/A'}"
puts "Organizations: #{Organization.count}"
puts "Users: #{User.count}"
puts "Patients: #{Patient.count}"
puts "Encounters: #{Encounter.count}"
puts "Vitals: #{Vital.count}"
puts "=" * 60
