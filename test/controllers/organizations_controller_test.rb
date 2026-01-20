require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    # We need a superadmin to access these routes
    @user = users(:superadmin)
    post session_url, params: { email_address: @user.email_address, password: "password123" }
  end

  test "should get index" do
    get admin_organizations_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_organization_url
    assert_response :success
  end

  test "should create organization" do
    # Use a random slug to guarantee uniqueness in the test database
    unique_slug = "test-org-#{SecureRandom.hex(4)}"

    assert_difference("Organization.count") do
      post admin_organizations_url, params: {
        organization: {
          name: "New Org",
          plan: "free",
          slug: unique_slug
        }
      }
    end

    # Find by the unique slug we just created
    created_org = Organization.find_by(slug: unique_slug)
    assert_redirected_to admin_organization_url(created_org)
  end

  test "should show organization" do
    get admin_organization_url(@organization)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_organization_url(@organization)
    assert_response :success
  end

  test "should update organization" do
    patch admin_organization_url(@organization), params: {
      organization: {
        name: "Updated Name",
        plan: "premium",
        slug: @organization.slug # Keep the existing valid slug
      }
    }
    assert_redirected_to admin_organization_url(@organization)
  end

  test "should destroy organization" do
    # Create an isolated organization to delete
    # This prevents foreign key issues with the fixtures or currently logged in user
    org_to_delete = Organization.create!(
      name: "Delete Me",
      slug: "delete-me-#{SecureRandom.hex(4)}",
      plan: "free"
    )

    assert_difference("Organization.count", -1) do
      delete admin_organization_url(org_to_delete)
    end

    assert_redirected_to admin_organizations_url
  end
end
