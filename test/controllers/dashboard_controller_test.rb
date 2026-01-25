require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "should get index" do
    get practice_dashboard_url(slug: @user.organization.slug)
    assert_response :success
  end
end
