class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  # This prevents issues where a user navigates to the wrong login URL and gets redirected immediately.
  skip_before_action :authorize_tenant!, only: %i[ new create destroy ]

  # Only apply rate limiting in non-test environments so we don't block our own test suite
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." } unless Rails.env.test? unless Rails.env.test?

  def new
    if authenticated?
      if Current.user.superadmin?
        redirect_to admin_organizations_path
      elsif Current.user.organization
        redirect_to practice_dashboard_path(slug: Current.user.organization.slug)
      end
    end
  end

  def create
    if user = User.authenticate_by(email_address: params[:email_address], password: params[:password])
      start_new_session_for user

      if user.superadmin?
        redirect_to admin_organizations_path
      else
        # We explicitly set the correct slug here, which overrides any bad slug from the URL
        redirect_to practice_dashboard_path(slug: user.organization.slug)
      end
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
