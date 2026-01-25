require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user must have an email address" do
    user = User.new(email_address: nil)
    assert_not user.save, "Saved the user without an email address"
  end

  test "destroying user destroys sent messages" do
    user = User.create!(
      email_address: "temp_destroy@example.com",
      password: "password",
      password_confirmation: "password",
      first_name: "Temp",
      last_name: "User",
      role: :staff,
      organization: organizations(:one)
    )

    recipient = users(:two)

    Message.create!(
      organization: user.organization,
      sender: user,
      recipient: recipient,
      subject: "Test Subject",
      body: "Test Body"
    )

    assert_difference("Message.count", -1) do
      user.destroy
    end
  end
end
