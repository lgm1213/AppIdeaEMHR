module Admin
  class OrganizationsController < Admin::BaseController
    def index
      @organizations = Organization.all.order(:name)
    end

    def show
      @organization = Organization.find(params[:id])
      # "Drill down" data:
      @facilities = @organization.facilities
      @users = @organization.users
    end
  end
end
