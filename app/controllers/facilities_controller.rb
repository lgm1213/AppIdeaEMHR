class FacilitiesController < ApplicationController
  before_action :set_facility, only: %i[ show edit update destroy ]

  # GET /:slug/facilities
  def index
    @facilities = @current_organization.facilities
  end

  # GET /:slug/facilities/1
  def show
  end

  # GET /:slug/facilities/new
  def new
    @facility = @current_organization.facilities.build
  end

  # GET /:slug/facilities/1/edit
  def edit
  end

  # POST /:slug/facilities
  def create
    @facility = @current_organization.facilities.build(facility_params)

    respond_to do |format|
      if @facility.save
        # Redirect to the index list (Rails keeps the current slug automatically)
        format.html { redirect_to facilities_path, notice: "Facility was successfully created." }
        format.json { render :show, status: :created, location: @facility }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @facility.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /:slug/facilities/1
  def update
    respond_to do |format|
      if @facility.update(facility_params)
        format.html { redirect_to facility_path(@facility), notice: "Facility was successfully updated." }
        format.json { render :show, status: :ok, location: @facility }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @facility.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /:slug/facilities/1
  def destroy
    @facility.destroy!

    respond_to do |format|
      format.html { redirect_to facilities_path, status: :see_other, notice: "Facility was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callback to share common setup or constraints between actions.
    def set_facility
      @facility = @current_organization.facilities.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def facility_params
      params.require(:facility).permit(:name, :phone, :address)
    end
end
