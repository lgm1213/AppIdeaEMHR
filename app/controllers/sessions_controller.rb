class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

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

      # Role-Based Redirection
      if user.superadmin?
        # Superadmins go to the Global Admin Area
        redirect_to admin_organizations_path
      else
        # Doctors/Staff go to their specific Clinic Dashboard
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
