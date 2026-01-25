require "test_helper"

class PatientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = patients(:one)
    @organization = @patient.organization

    @user = users(:one)
    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "should get index" do
    get patients_url(slug: @organization.slug)
    assert_response :success
  end

  test "should get new" do
    get new_patient_url(slug: @organization.slug)
    assert_response :success
  end

  test "should create patient" do
    assert_difference("Patient.count") do
      post patients_url(slug: @organization.slug), params: {
        patient: {
          date_of_birth: @patient.date_of_birth,
          email: "new_unique_email@example.com",
          first_name: @patient.first_name,
          gender: @patient.gender,
          last_name: @patient.last_name,
          phone: @patient.phone
        }
      }
    end

    assert_redirected_to patients_url(slug: @organization.slug)
  end

  test "should show patient" do
    get patient_url(slug: @organization.slug, id: @patient.id)
    assert_response :success
  end

  test "should get edit" do
    get edit_patient_url(slug: @organization.slug, id: @patient.id)
    assert_response :success
  end

  test "should update patient" do
    patch patient_url(slug: @organization.slug, id: @patient.id), params: {
      patient: { first_name: "Updated Name" }
    }
    assert_redirected_to patient_url(slug: @organization.slug, id: @patient.id)
  end

  test "should destroy patient" do
    assert_difference("Patient.count", -1) do
      delete patient_url(slug: @organization.slug, id: @patient.id)
    end

    assert_redirected_to patients_url(slug: @organization.slug)
  end
end
