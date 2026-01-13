require "test_helper"

class EncountersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @encounter = encounters(:one)
  end

  test "should get index" do
    get encounters_url
    assert_response :success
  end

  test "should get new" do
    get new_encounter_url
    assert_response :success
  end

  test "should create encounter" do
    assert_difference("Encounter.count") do
      post encounters_url, params: { encounter: { assessment: @encounter.assessment, objective: @encounter.objective, organization_id: @encounter.organization_id, patient_id: @encounter.patient_id, plan: @encounter.plan, provider_id: @encounter.provider_id, subjective: @encounter.subjective, visit_date: @encounter.visit_date } }
    end

    assert_redirected_to encounter_url(Encounter.last)
  end

  test "should show encounter" do
    get encounter_url(@encounter)
    assert_response :success
  end

  test "should get edit" do
    get edit_encounter_url(@encounter)
    assert_response :success
  end

  test "should update encounter" do
    patch encounter_url(@encounter), params: { encounter: { assessment: @encounter.assessment, objective: @encounter.objective, organization_id: @encounter.organization_id, patient_id: @encounter.patient_id, plan: @encounter.plan, provider_id: @encounter.provider_id, subjective: @encounter.subjective, visit_date: @encounter.visit_date } }
    assert_redirected_to encounter_url(@encounter)
  end

  test "should destroy encounter" do
    assert_difference("Encounter.count", -1) do
      delete encounter_url(@encounter)
    end

    assert_redirected_to encounters_url
  end
end
