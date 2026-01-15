module Admin
  class FacilitiesController < Admin::BaseController
    before_action :set_organization

    def new
      @facility = @organization.facilities.build
    end

    def create
      @facility = @organization.facilities.build(facility_params)

      if @facility.save
        redirect_to admin_organization_path(@organization), notice: "Facility added successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_organization
      @organization = Organization.find(params[:organization_id])
    end

    def facility_params
      # Adjust these fields based on your actual database columns
      params.require(:facility).permit(:name, :address, :city, :state, :zip_code, :phone)
    end
  end
end
