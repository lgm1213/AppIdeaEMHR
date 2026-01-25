require "test_helper"

class AppointmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @user = users(:one)
    login_as(@user)
    @appointment = appointments(:one)
    @patient = patients(:one)
    @provider = providers(:one)
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
    start = Time.current + 1.day
    assert_difference("Appointment.count") do
      post appointments_url(slug: @organization.slug), params: {
        appointment: {
          patient_id: @patient.id,
          provider_id: @provider.id,
          start_time: start,
          end_time: start + 30.minutes,
          duration_minutes: 30,
          status: "scheduled",
          reason: "Checkup"
        }
      }
    end

    assert_redirected_to appointments_url(slug: @organization.slug, date: start.to_date)
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
      appointment: { reason: "Updated Reason", status: "scheduled" }
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

  def login_as(user)
    # This simulates a logged-in session for Rails 8 Authentication
    # Ensure your password matches what is in your fixtures!
    post session_url, params: { email_address: user.email_address, password: "password" }
  end
end
