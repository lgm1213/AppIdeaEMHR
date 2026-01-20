require "test_helper"

class FacilitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @facility = facilities(:one)
    # Define the organization for the routing scope
    @organization = @facility.organization
    @user = users(:one)

    # Simulate logging in (assuming you have a helper or need to post to session)
    # If using your SessionController logic:
    post session_url, params: { email_address: @user.email_address, password: "password123" }
  end

  test "should get index" do
    # PASS SLUG
    get facilities_url(slug: @organization.slug)
    assert_response :success
  end

  test "should get new" do
    # PASS SLUG
    get new_facility_url(slug: @organization.slug)
    assert_response :success
  end

  test "should create facility" do
    assert_difference("Facility.count") do
      post facilities_url(slug: @organization.slug), params: {
        facility: {
          name: "New Facility",
          address: "123 Test St",
          city: "Miami",
          state: "FL",
          zip_code: "33101",
          phone: "555-0000"
        }
      }
    end

    # Expect redirect to the Index (List), not the Show page
    assert_redirected_to facilities_url(slug: @organization.slug)
  end

  test "should show facility" do
    # PASS SLUG & ID
    get facility_url(slug: @organization.slug, id: @facility.id)
    assert_response :success
  end

  test "should get edit" do
    # PASS SLUG & ID
    get edit_facility_url(slug: @organization.slug, id: @facility.id)
    assert_response :success
  end

  test "should update facility" do
    # PASS SLUG & ID
    patch facility_url(slug: @organization.slug, id: @facility.id), params: {
      facility: {
        name: "Updated Name"
      }
    }
    assert_redirected_to facility_url(slug: @organization.slug, id: @facility.id)
  end

  test "should destroy facility" do
    assert_difference("Facility.count", -1) do
      # PASS SLUG & ID
      delete facility_url(slug: @organization.slug, id: @facility.id)
    end

    assert_redirected_to facilities_url(slug: @organization.slug)
  end
end
