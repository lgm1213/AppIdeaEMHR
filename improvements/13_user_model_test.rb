# frozen_string_literal: true

# ==============================================================================
# BONUS IMPROVEMENT: User Model Tests
# ==============================================================================
# File: test/models/user_test.rb
#
# Comprehensive test coverage for the User model
# ==============================================================================

require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:one)
    @user = users(:one)
  end

  # ===========================================================================
  # Validations
  # ===========================================================================
  test "valid user" do
    user = User.new(
      email_address: "newuser@example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "New",
      last_name: "User",
      organization: @organization
    )
    assert user.valid?
  end

  test "invalid without email_address" do
    @user.email_address = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email_address], "can't be blank"
  end

  test "invalid with duplicate email_address" do
    duplicate = @user.dup
    duplicate.email_address = @user.email_address
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email_address], "has already been taken"
  end

  test "invalid with malformed email_address" do
    @user.email_address = "not-an-email"
    assert_not @user.valid?
    assert_includes @user.errors[:email_address], "must be a valid email address"
  end

  test "email uniqueness is case insensitive" do
    duplicate = @user.dup
    duplicate.email_address = @user.email_address.upcase
    assert_not duplicate.valid?
  end

  # ===========================================================================
  # Normalizations
  # ===========================================================================
  test "normalizes email_address to lowercase and strips whitespace" do
    @user.email_address = "  TEST@EXAMPLE.COM  "
    @user.save!
    assert_equal "test@example.com", @user.email_address
  end

  # ===========================================================================
  # Password
  # ===========================================================================
  test "has_secure_password works" do
    user = User.new(
      email_address: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
      organization: @organization
    )
    assert user.authenticate("password123")
    assert_not user.authenticate("wrongpassword")
  end

  test "password confirmation must match" do
    user = User.new(
      email_address: "test@example.com",
      password: "password123",
      password_confirmation: "different",
      organization: @organization
    )
    assert_not user.valid?
    assert_includes user.errors[:password_confirmation], "doesn't match Password"
  end

  # ===========================================================================
  # Enum: Role
  # ===========================================================================
  test "default role is staff" do
    user = User.new(
      email_address: "new@example.com",
      password: "password123",
      organization: @organization
    )
    assert user.staff?
  end

  test "role enum values" do
    assert_equal({ "staff" => 0, "provider" => 1, "admin" => 2, "superadmin" => 3 }, User.roles)
  end

  test "staff? returns true for staff role" do
    @user.role = :staff
    assert @user.staff?
    assert_not @user.provider?
    assert_not @user.admin?
    assert_not @user.superadmin?
  end

  test "provider? returns true for provider role" do
    @user.role = :provider
    assert @user.provider?
  end

  test "admin? returns true for admin role" do
    @user.role = :admin
    assert @user.admin?
  end

  test "superadmin? returns true for superadmin role" do
    @user.role = :superadmin
    assert @user.superadmin?
  end

  # ===========================================================================
  # Name Methods
  # ===========================================================================
  test "full_name returns first and last name" do
    @user.first_name = "John"
    @user.last_name = "Doe"
    assert_equal "John Doe", @user.full_name
  end

  test "full_name returns email when names are blank" do
    @user.first_name = nil
    @user.last_name = nil
    assert_equal @user.email_address, @user.full_name
  end

  test "initials returns uppercase first letters" do
    @user.first_name = "John"
    @user.last_name = "Doe"
    assert_equal "JD", @user.initials
  end

  test "initials handles missing names" do
    @user.first_name = nil
    @user.last_name = nil
    assert_equal "??", @user.initials
  end

  # ===========================================================================
  # Role Helper Methods
  # ===========================================================================
  test "can_manage_users? returns true for admin" do
    @user.role = :admin
    assert @user.can_manage_users?
  end

  test "can_manage_users? returns true for superadmin" do
    @user.role = :superadmin
    assert @user.can_manage_users?
  end

  test "can_manage_users? returns false for staff and provider" do
    @user.role = :staff
    assert_not @user.can_manage_users?

    @user.role = :provider
    assert_not @user.can_manage_users?
  end

  test "can_access_billing? returns true for admin, superadmin, provider" do
    [ :admin, :superadmin, :provider ].each do |role|
      @user.role = role
      assert @user.can_access_billing?, "Expected #{role} to access billing"
    end
  end

  test "can_access_billing? returns false for staff" do
    @user.role = :staff
    assert_not @user.can_access_billing?
  end

  # ===========================================================================
  # Provider Association
  # ===========================================================================
  test "is_provider? returns true when role is provider and has provider record" do
    @user.role = :provider
    @user.save!

    Provider.create!(
      user: @user,
      organization: @organization,
      npi: "9876543210",
      license_number: "TEST-123"
    )

    assert @user.is_provider?
  end

  test "is_provider? returns false when role is provider but no provider record" do
    @user.role = :provider
    @user.provider&.destroy
    assert_not @user.reload.is_provider?
  end

  test "is_provider? returns false for non-provider role" do
    @user.role = :staff
    assert_not @user.is_provider?
  end

  # ===========================================================================
  # Messaging
  # ===========================================================================
  test "unread_messages_count returns correct count" do
    # Clear existing messages
    @user.received_messages.destroy_all

    # Create unread messages
    3.times do
      Message.create!(
        organization: @organization,
        sender: users(:two),
        recipient: @user,
        patient: patients(:one),
        subject: "Test",
        body: "Test body",
        read_at: nil
      )
    end

    # Create read message
    Message.create!(
      organization: @organization,
      sender: users(:two),
      recipient: @user,
      patient: patients(:one),
      subject: "Read",
      body: "Already read",
      read_at: Time.current
    )

    assert_equal 3, @user.unread_messages_count
  end

  # ===========================================================================
  # Associations
  # ===========================================================================
  test "destroying user destroys sessions" do
    Session.create!(user: @user)

    assert_difference("Session.count", -@user.sessions.count) do
      @user.destroy
    end
  end

  test "destroying user destroys sent messages" do
    Message.create!(
      organization: @organization,
      sender: @user,
      recipient: users(:two),
      patient: patients(:one),
      subject: "Test",
      body: "Test"
    )

    assert_difference("Message.count", -@user.sent_messages.count) do
      @user.destroy
    end
  end

  test "organization is optional" do
    @user.organization = nil
    @user.role = :superadmin
    assert @user.valid?
  end

  # ===========================================================================
  # Scopes
  # ===========================================================================
  test "by_organization scope filters correctly" do
    org_users = User.by_organization(@organization)
    assert org_users.all? { |u| u.organization_id == @organization.id }
  end

  test "clinical_staff scope returns providers and admins" do
    results = User.clinical_staff
    assert results.all? { |u| u.provider? || u.admin? }
  end
end
