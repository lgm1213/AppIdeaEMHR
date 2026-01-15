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

    def new
      @organization = Organization.new
    end

    def create
      @organization = Organization.new(organization_params)

      if @organization.save
        redirect_to admin_organizations_path, notice: "New practice '#{@organization.name}' created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def organization_params
      params.require(:organization).permit(:name, :slug)
    end
  end
end
