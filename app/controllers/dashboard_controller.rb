class DashboardController < ApplicationController
  def index
    @user = Current.user
    @organization = @user.organization

    # If the user has an organization, load its facilities, we use safe navigation (&.) just in case a user has no org yet.
    @facilities = @organization&.facilities || []
  end
end
