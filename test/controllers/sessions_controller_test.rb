require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    # Use 'password' to match your updated fixtures
    post session_path, params: { email_address: @user.email_address, password: "password" }

    # Adjust expected redirect if your app goes to dashboard instead of root
    assert_redirected_to practice_dashboard_url(slug: @user.organization.slug)
    # assert cookies[:session_id] # (Optional: depends if you use cookies or session store)
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
  end

  test "destroy" do
    # Log in first
    post session_path, params: { email_address: @user.email_address, password: "password" }

    delete session_path
    assert_redirected_to new_session_path
  end
end
