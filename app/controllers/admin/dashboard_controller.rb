module Admin
  class DashboardController < ApplicationController
    before_action :ensure_superadmin!

    layout "admin"

    def index
      @organizations = Organization.all
      @total_users = User.count
      @recent_signups = User.order(created_at: :desc).limit(5)
    end

    private

    def ensure_superadmin!
      unless Current.user&.superadmin?
        redirect_to root_path, alert: "Access Denied."
      end
    end
  end
end
