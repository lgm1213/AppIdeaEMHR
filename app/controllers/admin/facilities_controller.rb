module Admin
  class FacilitiesController < Admin::BaseController
    before_action :set_organization
    before_action :set_facility, only: [ :show, :edit, :update ]

    def new
      @facility = @organization.facilities.build
    end

    def create
      @facility = @organization.facilities.build(facility_params)

      if @facility.save
        redirect_to admin_organization_path(@organization), notice: "Facility added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      # Renders app/views/admin/facilities/show.html.erb
    end

    def edit
      # Renders app/views/admin/facilities/edit.html.erb
    end

    def update
      if @facility.update(facility_params)
        redirect_to admin_organization_path(@organization), notice: "Facility updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_organization
      @organization = Organization.find(params[:organization_id])
    end

    def set_facility
      @facility = @organization.facilities.find(params[:id])
    end

    def facility_params
      params.require(:facility).permit(:name, :address, :city, :state, :zip_code, :phone)
    end
  end
end
