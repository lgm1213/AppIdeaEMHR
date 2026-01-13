class RegistrationsController < ApplicationController
  skip_before_action :require_authentication

  def new
    @organization = Organization.new
    @organization.users.build
  end

  def create
    @organization = Organization.new(registration_params)

    # Hardcodes the role of 'admin' for the user creating the account
    @organization.users.first.role = :admin

    if @organization.save
      # Logs the user in immediately
      user = @organization.users.first
      start_new_session_for user
      redirect_to practice_dashboard_path(slug: @organization.slug), notice: "Welcome to AppIdea Health! Your practice is ready."
    else
      # If it fails, render the form again so they can fix errors
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:organization).permit(:name, users_attributes: [ :email_address, :password, :password_confirmation ])
  end
end
