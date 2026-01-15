module Admin
  class OrganizationsController < Admin::BaseController
    before_action :set_organization, only: [ :show, :edit, :update ]

    def index
      @organizations = Organization.all.order(:name)
    end

    def show
      @facilities = @organization.facilities
      @users = @organization.users
    end

    def new
      @organization = Organization.new
    end

    def create
      @organization = Organization.new(organization_params)

      if @organization.save
        redirect_to admin_organization_path(@organization), notice: "New practice '#{@organization.name}' created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @organization.update(organization_params)
        redirect_to admin_organization_path(@organization), notice: "Organization details updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_organization
      @organization = Organization.find(params[:id])
    end

    def organization_params
      params.require(:organization).permit(:name, :slug, :plan)
    end
  end
end
