class EncountersController < ApplicationController
  before_action :set_patient
  before_action :set_encounter, only: %i[ show edit update destroy ]

  # GET /:slug/patients/:patient_id/encounters
  def index
    @encounters = @patient.encounters.includes(:provider).order(visit_date: :desc)
  end

  # GET /:slug/patients/:patient_id/encounters/1
  def show
  end

  # GET /:slug/patients/:patient_id/encounters/new
  def new
    @encounter = @patient.encounters.build

    # Auto-fill the provider if the current user is a doctor
    if Current.user&.is_provider?
      @encounter.provider = Current.user.provider
    end

    @encounter.visit_date = Time.current
  end

  # POST /:slug/patients/:patient_id/encounters
  def create
    @encounter = @patient.encounters.build(encounter_params)
    @encounter.organization = @current_organization

    # If the user didn't select a provider, default to the logged-in provider
    if @encounter.provider_id.blank? && Current.user&.is_provider?
      @encounter.provider = Current.user.provider
    end

    if @encounter.save
      redirect_to patient_encounters_path(@current_organization.slug, @patient), notice: "SOAP note saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /:slug/patients/:patient_id/encounters/1/edit
  def edit
  end

  # PATCH/PUT /:slug/patients/:patient_id/encounters/1
  def update
    if @encounter.update(encounter_params)
      redirect_to patient_encounters_path(@current_organization.slug, @patient), notice: "SOAP note updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @encounter.destroy
    redirect_to patient_encounters_path(@current_organization.slug, @patient), notice: "Encounter deleted."
  end

  private

  def set_patient
    # We find the patient via the URL param :patient_id
    @patient = @current_organization.patients.find(params[:patient_id])
  end

  def set_encounter
    @encounter = @patient.encounters.find(params[:id])
  end

  def encounter_params
    params.require(:encounter).permit(:visit_date, :subjective, :objective, :assessment, :plan, :provider_id)
  end
end
