# frozen_string_literal: true

# ==============================================================================
# BONUS IMPROVEMENT: Patient Model Tests
# ==============================================================================
# File: test/models/patient_test.rb
#
# Comprehensive test coverage for the Patient model
# ==============================================================================

require "test_helper"

class PatientTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:one)
    @patient = patients(:one)
  end

  # ===========================================================================
  # Validations
  # ===========================================================================
  test "valid patient" do
    patient = Patient.new(
      organization: @organization,
      first_name: "John",
      last_name: "Doe",
      date_of_birth: 30.years.ago
    )
    assert patient.valid?
  end

  test "invalid without first_name" do
    @patient.first_name = nil
    assert_not @patient.valid?
    assert_includes @patient.errors[:first_name], "can't be blank"
  end

  test "invalid without last_name" do
    @patient.last_name = nil
    assert_not @patient.valid?
    assert_includes @patient.errors[:last_name], "can't be blank"
  end

  test "invalid without date_of_birth" do
    @patient.date_of_birth = nil
    assert_not @patient.valid?
    assert_includes @patient.errors[:date_of_birth], "can't be blank"
  end

  test "invalid without organization" do
    @patient.organization = nil
    assert_not @patient.valid?
    assert_includes @patient.errors[:organization], "must exist"
  end

  test "invalid with future date_of_birth" do
    @patient.date_of_birth = 1.day.from_now
    assert_not @patient.valid?
    assert_includes @patient.errors[:date_of_birth], "cannot be in the future"
  end

  test "valid email format" do
    @patient.email = "valid@example.com"
    assert @patient.valid?
  end

  test "invalid email format" do
    @patient.email = "invalid-email"
    assert_not @patient.valid?
  end

  test "allows blank email" do
    @patient.email = ""
    assert @patient.valid?
  end

  # ===========================================================================
  # Normalizations
  # ===========================================================================
  test "normalizes email to lowercase" do
    @patient.email = "  TEST@EXAMPLE.COM  "
    @patient.save!
    assert_equal "test@example.com", @patient.email
  end

  test "normalizes names to titlecase" do
    @patient.first_name = "  john  "
    @patient.last_name = "DOE"
    @patient.save!
    assert_equal "John", @patient.first_name
    assert_equal "Doe", @patient.last_name
  end

  test "normalizes phone to digits only" do
    @patient.phone = "(305) 555-1234"
    @patient.save!
    assert_equal "3055551234", @patient.phone
  end

  # ===========================================================================
  # Name Methods
  # ===========================================================================
  test "full_name returns last_name, first_name format" do
    @patient.first_name = "John"
    @patient.last_name = "Doe"
    assert_equal "Doe, John", @patient.full_name
  end

  test "display_name returns first_name last_name format" do
    @patient.first_name = "John"
    @patient.last_name = "Doe"
    assert_equal "John Doe", @patient.display_name
  end

  test "initials returns uppercase first letters" do
    @patient.first_name = "John"
    @patient.last_name = "Doe"
    assert_equal "JD", @patient.initials
  end

  # ===========================================================================
  # Age Calculations
  # ===========================================================================
  test "age returns correct years" do
    @patient.date_of_birth = 30.years.ago
    assert_equal 30, @patient.age
  end

  test "age handles birthday not yet passed this year" do
    # Set DOB to 30 years ago plus 1 month from now
    future_birthday = 30.years.ago + 1.month
    @patient.date_of_birth = future_birthday
    assert_equal 29, @patient.age
  end

  test "age returns nil when no date_of_birth" do
    @patient.date_of_birth = nil
    assert_nil @patient.age
  end

  test "age_display for infant shows months" do
    @patient.date_of_birth = 6.months.ago
    assert_match(/months/, @patient.age_display)
  end

  test "age_display for newborn" do
    @patient.date_of_birth = 2.weeks.ago
    assert_equal "Newborn", @patient.age_display
  end

  test "age_display for adult shows years" do
    @patient.date_of_birth = 30.years.ago
    assert_equal "30 years", @patient.age_display
  end

  test "minor? returns true for under 18" do
    @patient.date_of_birth = 10.years.ago
    assert @patient.minor?
  end

  test "minor? returns false for 18 and over" do
    @patient.date_of_birth = 18.years.ago
    assert_not @patient.minor?
  end

  test "geriatric? returns true for 65 and over" do
    @patient.date_of_birth = 70.years.ago
    assert @patient.geriatric?
  end

  test "geriatric? returns false for under 65" do
    @patient.date_of_birth = 50.years.ago
    assert_not @patient.geriatric?
  end

  # ===========================================================================
  # Address Methods
  # ===========================================================================
  test "full_address joins address components" do
    @patient.street_address = "123 Main St"
    @patient.city = "Miami"
    @patient.state = "FL"
    @patient.zip_code = "33101"
    assert_equal "123 Main St, Miami, FL, 33101", @patient.full_address
  end

  test "full_address handles missing components" do
    @patient.street_address = nil
    @patient.city = "Miami"
    @patient.state = "FL"
    @patient.zip_code = nil
    assert_equal "Miami, FL", @patient.full_address
  end

  test "city_state_zip formats correctly" do
    @patient.city = "Miami"
    @patient.state = "FL"
    @patient.zip_code = "33101"
    assert_equal "Miami, FL 33101", @patient.city_state_zip
  end

  # ===========================================================================
  # Scopes
  # ===========================================================================
  test "search scope finds by first_name" do
    results = Patient.search(@patient.first_name)
    assert_includes results, @patient
  end

  test "search scope finds by last_name" do
    results = Patient.search(@patient.last_name)
    assert_includes results, @patient
  end

  test "search scope finds by email" do
    @patient.update!(email: "unique@test.com")
    results = Patient.search("unique@test")
    assert_includes results, @patient
  end

  test "by_name scope orders alphabetically" do
    results = Patient.by_name.pluck(:last_name)
    assert_equal results.sort, results
  end

  # ===========================================================================
  # Associations
  # ===========================================================================
  test "destroying patient destroys associated encounters" do
    patient = patients(:one)
    # Count how many encounters this specific patient actually has in fixtures
    encounter_count = patient.encounters.count

    assert encounter_count > 0, "Patient needs encounters for this test"

    assert_difference("Encounter.count", -encounter_count) do
      patient.destroy
    end
  end

  test "has_allergies? returns true when allergies exist" do
    patient = patients(:one)
    patient.allergies.create!(name: "Dust", severity: "Mild", status: "Active")
    assert patient.has_allergies?
  end

  test "has_no_known_allergies? returns true when no allergies" do
    @patient.allergies.destroy_all
    assert @patient.has_no_known_allergies?
  end
end
