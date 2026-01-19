class EncountersController < ApplicationController
  before_action :set_encounter, only: [ :show, :edit, :update, :destroy, :superbill, :hcfa ]
  before_action :set_patient

  def index
    @encounters = @patient.encounters.order(visit_date: :desc)
  end

  def show
  end

  def new
    @encounter = @patient.encounters.build
    @encounter.visit_date = Time.current
    # Set default provider to current user if they are a provider
    @encounter.provider = @current_organization.providers.find_by(user: Current.user)
  end

  def edit
  end

  def create
    @encounter = @patient.encounters.build(encounter_params)
    @encounter.organization = @current_organization

    if @encounter.save
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), notice: "Encounter note saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @encounter.update(encounter_params)
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), notice: "Encounter note updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @encounter.destroy
    redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), notice: "Encounter deleted."
  end

  # GET /encounters/:id/superbill
  def superbill
    pdf = SuperbillGenerator.new(@encounter).call

    send_data pdf,
              filename: "Superbill_#{@encounter.patient.last_name}_#{@encounter.visit_date}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  # GET /encounters/:id/hfca
  def hcfa
    # Default to :print (text only) for physical mail
    # Pass ?mode=digital to get the full PDF for email/storage
    mode = params[:mode] == "digital" ? :digital : :print

    pdf = Cms1500Generator.new(@encounter, mode: mode).call

    filename = mode == :digital ? "Claim_#{@encounter.id}_FULL.pdf" : "Claim_#{@encounter.id}_PRINT.pdf"

    send_data pdf,
              filename: filename,
              type: "application/pdf",
              disposition: "inline"
  end

  private

  def set_encounter
    # Find the encounter by ID (scoped to organization for security)
    @encounter = @current_organization.encounters.find(params[:id])
  end

  def set_patient
    if @encounter
      # If we already found the encounter, the patient is attached to it!
      @patient = @encounter.patient
    elsif params[:patient_id]
      # Otherwise (like in 'new' or 'create'), use the URL param
      @patient = @current_organization.patients.find(params[:patient_id])
    else
      # Safety net
      redirect_to patients_path(slug: @current_organization.slug), alert: "Patient context missing."
    end
  end

  def encounter_params
    params.require(:encounter).permit(
      :patient_id, :provider_id, :visit_date, :appointment_id,
      :subjective, :objective, :assessment, :plan,
      procedure_ids: [] # Allow the checkbox array
    )
  end
end
