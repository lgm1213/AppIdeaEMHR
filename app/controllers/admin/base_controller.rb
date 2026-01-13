module Admin
  class BaseController < ApplicationController
    layout "admin" # Optional: Use a different layout (e.g. dark sidebar) to distinguish it

    before_action :require_superadmin!

    private

    def require_superadmin!
      # Assuming you set the role enum to: { staff: 0, provider: 1, admin: 2, superadmin: 3 }
      unless Current.user&.superadmin?
        redirect_to root_path, alert: "Access Denied. You do not have permission to view this area."
      end
    end
  end
end
