class PagesController < ApplicationController
  # We allow unauthenticated access so people can see the login button/marketing info
  allow_unauthenticated_access only: :home

  def home
    if authenticated?
      if Current.user.superadmin?
        redirect_to admin_root_path
      elsif Current.user.organization
        redirect_to practice_dashboard_path(slug: Current.user.organization.slug)
      end
    end
  end
end
