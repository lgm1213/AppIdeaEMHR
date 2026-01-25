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
      u.password = "password123"
      u.password_confirmation = "password123"
      u.role = :admin
      u.organization = @demo_org
    end
    puts "  → Admin: admin@demo.com / password123"

    # Provider user with credentials
    @provider_user = User.find_or_create_by!(email_address: "doctor@demo.com") do |u|
      u.first_name = "Jane"
      u.last_name = "Smith"
      u.password = "password123"
      u.password_confirmation = "password123"
      u.role = :provider
      u.organization = @demo_org
    end

    Provider.find_or_create_by!(user: @provider_user) do |p|
      p.organization = @demo_org
      p.npi = "1234567890"
      p.license_number = "FL-MD-12345"
      p.specialty = "Family Medicine"
      p.taxonomy_code = "207Q00000X"
    end
    puts "  → Provider: doctor@demo.com / password123 (Dr. Jane Smith)"

    # Staff user
    User.find_or_create_by!(email_address: "staff@demo.com") do |u|
      u.first_name = "Staff"
      u.last_name = "Member"
      u.password = "password123"
      u.password_confirmation = "password123"
      u.role = :staff
      u.organization = @demo_org
    end
    puts "  → Staff: staff@demo.com / password123"

    # Superadmin (no organization)
    User.find_or_create_by!(email_address: "superadmin@demo.com") do |u|
      u.first_name = "Super"
      u.last_name = "Admin"
      u.password = "password123"
      u.password_confirmation = "password123"
      u.role = :superadmin
      u.organization = nil
    end
    puts "  → Superadmin: superadmin@demo.com / password123"
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
end

# ===========================================================================
# Summary
# ===========================================================================
puts "\n#{"=" * 60}"
puts "SEED COMPLETE"
puts "=" * 60
puts "CPT Codes: #{CptCode.count}"
puts "ICD Codes: #{IcdCode.count}" if defined?(IcdCode)
puts "Organizations: #{Organization.count}"
puts "Users: #{User.count}"
puts "Patients: #{Patient.count}"
puts "Procedures: #{Procedure.count}"
puts "=" * 60
