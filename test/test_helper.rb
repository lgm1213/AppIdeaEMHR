ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all

    def login_as(user)
      # FIX: Force the password to be "password" in the database right now.
      # This guarantees it matches what we send below.
      user.update!(password: "password", password_confirmation: "password")

      # Send the login request
      post session_url, params: { email_address: user.email_address, password: "password" }

      # Handle potential nested params (just in case)
      if response.redirect_url && response.redirect_url.include?("/session/new")
        post session_url, params: { session: { email_address: user.email_address, password: "password" } }
      end

      assert_response :redirect
      assert_not response.redirect_url&.include?("/session/new"), "Login failed! Redirected back to login."
      follow_redirect!
    end
  end
end
