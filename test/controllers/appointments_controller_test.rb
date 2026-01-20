require "test_helper"

class AppointmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @appointment = appointments(:one)
    @organization = @appointment.organization
    @user = users(:one)
    post session_url, params: { email_address: @user.email_address, password: "password123" }
  end

  test "should get index" do
    get appointments_url(slug: @organization.slug)
    assert_response :success
  end

  test "should get new" do
    get new_appointment_url(slug: @organization.slug)
    assert_response :success
  end

  test "should create appointment" do
    assert_difference("Appointment.count") do
      post appointments_url(slug: @organization.slug), params: {
        appointment: {
          end_time: @appointment.end_time,
          patient_id: @appointment.patient_id,
          provider_id: @appointment.provider_id,
          reason: @appointment.reason,
          start_time: @appointment.start_time,
          status: @appointment.status
        }
      }
    end

    # Expect redirect with date param
    assert_redirected_to appointments_url(slug: @organization.slug, date: @appointment.start_time.to_date)
  end

  test "should show appointment" do
    get appointment_url(slug: @organization.slug, id: @appointment.id)
    assert_response :success
  end

  test "should get edit" do
    get edit_appointment_url(slug: @organization.slug, id: @appointment.id)
    assert_response :success
  end

  test "should update appointment" do
    patch appointment_url(slug: @organization.slug, id: @appointment.id), params: {
      appointment: { reason: "Updated Reason" }
    }
    # Expect redirect to Index with date param
    assert_redirected_to appointments_url(slug: @organization.slug, date: @appointment.start_time.to_date)
  end

  test "should destroy appointment" do
    assert_difference("Appointment.count", -1) do
      delete appointment_url(slug: @organization.slug, id: @appointment.id)
    end

    # Expect redirect with date param
    assert_redirected_to appointments_url(slug: @organization.slug, date: @appointment.start_time.to_date)
  end
end
