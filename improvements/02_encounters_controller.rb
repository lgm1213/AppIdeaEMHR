# frozen_string_literal: true

# ==============================================================================
# IMPROVEMENT #2: Fix N+1 Queries in EncountersController
# ==============================================================================
# File: app/controllers/encounters_controller.rb
#
# Changes:
# - Added eager loading in set_encounter for PDF generation
# - Added eager loading in index action
# - Extracted common includes into a constant
# ==============================================================================

class EncountersController < ApplicationController
  before_action :set_organization
  before_action :set_encounter, only: [ :show, :edit, :update, :destroy, :superbill, :hcfa ]
  before_action :set_patient

  # Common includes for encounter queries to prevent N+1
  ENCOUNTER_INCLUDES = [
    :provider,
    :organization,
    :appointment,
    { patient: [ :conditions, :allergies ] },
    { encounter_procedures: :procedure },
    :encounter_diagnoses
  ].freeze

  def index
    @encounters = @patient.encounters
                          .includes(:provider, :encounter_procedures, :encounter_diagnoses)
                          .order(visit_date: :desc)
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
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"),
                  notice: "Encounter note saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @encounter.update(encounter_params)
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"),
                  notice: "Encounter note updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @encounter.destroy
    redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"),
                notice: "Encounter deleted."
  end

  # GET /encounters/:id/superbill
  def superbill
    pdf = SuperbillGenerator.new(@encounter).call

    send_data pdf,
              filename: "Superbill_#{@encounter.patient.last_name}_#{@encounter.visit_date.strftime('%Y%m%d')}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  # GET /encounters/:id/hcfa
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
    # Eager load all associations needed for show/edit/PDF generation
    # This prevents N+1 queries in superbill and hcfa actions
    @encounter = @current_organization
                   .encounters
                   .includes(ENCOUNTER_INCLUDES)
                   .find(params[:id])
  end

  def set_organization
    @organization = Organization.find_by!(slug: params[:slug])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Organization not found."
  end

  def set_patient
    if @encounter
      # If we already found the encounter, the patient is attached to it
      @patient = @encounter.patient
    elsif params[:patient_id]
      # For nested routes (new, create, index)
      @patient = @current_organization.patients.find(params[:patient_id])
    end
  end

  def encounter_params
    params.require(:encounter).permit(
      :visit_date,
      :provider_id,
      :appointment_id,
      :subjective,
      :objective,
      :assessment,
      :plan,
      encounter_procedures_attributes: [
        :id,
        :procedure_id,
        :charge_amount,
        :units,
        :modifiers,
        :cpt_code_search_value,
        :_destroy
      ],
      encounter_diagnoses_attributes: [
        :id,
        :icd_code,
        :description,
        :_destroy
      ]
    )
  end
end
