require "test_helper"

class EncountersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @encounter = encounters(:one)
    @patient = @encounter.patient
    @organization = @encounter.organization

    # Simulate login
    @user = users(:one)
    post session_url, params: { email_address: @user.email_address, password: "password123" }
  end

  test "should get index" do
    # Index is nested under Patient
    get patient_encounters_url(slug: @organization.slug, patient_id: @patient.id)
    assert_response :success
  end

  test "should get new" do
    # New is nested under Patient
    get new_patient_encounter_url(slug: @organization.slug, patient_id: @patient.id)
    assert_response :success
  end

  test "should create encounter" do
    assert_difference("Encounter.count") do
      post patient_encounters_url(slug: @organization.slug, patient_id: @patient.id), params: {
        encounter: {
          assessment: @encounter.assessment,
          objective: @encounter.objective,
          plan: @encounter.plan,
          provider_id: @encounter.provider_id,
          subjective: @encounter.subjective,
          visit_date: @encounter.visit_date
        }
      }
    end

    # Expect redirect to the Patient's Clinical Tab
    assert_redirected_to patient_path(slug: @organization.slug, id: @patient.id, tab: "clinical")
  end

  test "should show encounter" do
    # Show is shallow (not nested)
    get encounter_url(slug: @organization.slug, id: @encounter.id)
    assert_response :success
  end

  test "should get edit" do
    get edit_encounter_url(slug: @organization.slug, id: @encounter.id)
    assert_response :success
  end

  test "should update encounter" do
    patch encounter_url(slug: @organization.slug, id: @encounter.id), params: {
      encounter: { assessment: "Updated Assessment" }
    }
    # Expect redirect to Patient's Clinical Tab
    assert_redirected_to patient_path(slug: @organization.slug, id: @patient.id, tab: "clinical")
  end

  test "should destroy encounter" do
    assert_difference("Encounter.count", -1) do
      delete encounter_url(slug: @organization.slug, id: @encounter.id)
    end

    # Expect redirect to Patient's Clinical Tab
    assert_redirected_to patient_path(slug: @organization.slug, id: @patient.id, tab: "clinical")
  end
end
