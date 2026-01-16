class PatientsController < ApplicationController
  before_action :set_patient, only: %i[ show edit update destroy download_ccda]

  # GET /:slug/patients
  def index
    # Scoped to the current organization
    @patients = @current_organization.patients.order(:last_name, :first_name)
  end

  # GET /:slug/patients/1
  def show
    # Handles Tabs
    @active_tab = params[:tab] || "overview"

    # Lazy Loads Audit Logs only if requested
    if @active_tab == "audit"
      @audit_logs = PaperTrail::Version
                      .where(item_type: "Patient", item_id: @patient.id)
                      .or(PaperTrail::Version.where(patient_id: @patient.id))
                      .order(created_at: :desc)
                      .includes(:item) # Optional: eager load items if needed
    end
  end

  # GET /:slug/patients/new
  def new
    @patient = @current_organization.patients.build
  end

  # GET /:slug/patients/1/edit
  def edit
  end

  # POST /:slug/patients
  def create
    @patient = @current_organization.patients.build(patient_params)

    respond_to do |format|
      if @patient.save
        format.html { redirect_to patients_path, notice: "Patient was successfully created." }
        format.json { render :show, status: :created, location: @patient }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /:slug/patients/1
  def update
    respond_to do |format|
      if @patient.update(patient_params)
        format.html { redirect_to patient_path(@patient), notice: "Patient was successfully updated." }
        format.json { render :show, status: :ok, location: @patient }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /:slug/patients/1
  def destroy
    @patient.destroy!

    respond_to do |format|
      format.html { redirect_to patients_path, status: :see_other, notice: "Patient was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def download_ccda
    # Generates XML
    xml_content = CcdaGenerator.new(@patient).call

    # Creates a professional filename
    filename = "CCDA_#{@patient.last_name}_#{@patient.first_name}_#{Date.today}.xml"

    # Sends to browser
    send_data xml_content,
              filename: filename,
              type: "application/xml",
              disposition: "attachment"
  end

  private
    def set_patient
      @patient = @current_organization.patients.find(params[:id])
    end

    def patient_params
      params.require(:patient).permit(:first_name, :last_name, :date_of_birth, :gender, :phone, :email)
    end
end
