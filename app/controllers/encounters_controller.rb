class EncountersController < ApplicationController
  before_action :set_organization
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
    @encounter.build_vital if @encounter.vital.nil?
  end

  def create
    @encounter = @patient.encounters.build(encounter_params)
    @encounter.organization = @organization

    # 1. Determine Intent
    is_finalizing = params[:commit] == "Finalize Encounter"
    @encounter.status = is_finalizing ? :finalized : :draft

    if @encounter.save
      respond_to do |format|
        if is_finalizing
          # A. Finalize: Go to the Review/Show page (Summary)
          format.html { redirect_to encounter_path(@encounter), notice: "Encounter signed and finalized." }
        else
          # B. Draft (Enter Key): Stay here, Switch context to Edit
          format.turbo_stream do
            flash.now[:notice] = "Draft saved..."
            render turbo_stream: [
              turbo_stream.replace("flash", partial: "layouts/flash"),
              # IMPORTANT: Update the browser URL to the 'edit' path without reloading
              # This prevents duplicate creations if the user refreshes the page.
              turbo_stream.append("body", "<script>history.pushState({}, '', '#{edit_encounter_path(@encounter)}')</script>"),
              turbo_stream.replace("encounter-form", partial: "encounters/form", locals: { encounter: @encounter })
            ]
          end
        end
      end
    else
      # --- Error Handling Logic ---
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          flash.now[:alert] = @encounter.errors.full_messages.join(", ")
          render turbo_stream: turbo_stream.replace("flash", partial: "layouts/flash")
        end
      end
    end
  end

  def update
    is_finalizing = params[:commit] == "Finalize Encounter"
    @encounter.status = is_finalizing ? :finalized : :draft

    if @encounter.update(encounter_params)
      respond_to do |format|
        if is_finalizing
          # Finalize: Go to the Review/Show page
          format.html { redirect_to encounter_path(@encounter), notice: "Encounter updated and finalized." }
        else
          # Draft (Enter Key): Stay here, Flash 'Saved'
          format.turbo_stream do
            flash.now[:notice] = "Draft saved..."
            render turbo_stream: [
              turbo_stream.replace("flash", partial: "layouts/flash"),
              turbo_stream.replace("encounter-form", partial: "encounters/form", locals: { encounter: @encounter })
            ]
          end
        end
      end
    else
      # Error handling (same as before)
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          flash.now[:alert] = @encounter.errors.full_messages.join(", ")
          render turbo_stream: turbo_stream.replace("flash", partial: "layouts/flash")
        end
      end
    end
  end

  def destroy
    @encounter.destroy
    redirect_to patient_path(slug: @organization.slug, id: @patient.id, tab: "clinical"), notice: "Encounter deleted."
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
    @encounter = @organization.encounters.find(params[:id])
  end

  def set_organization
    @organization = Organization.find_by!(slug: params[:slug])
    @current_organization = @organization
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Organization not found."
  end

  def set_patient
    if @encounter
      @patient = @encounter.patient
    elsif params[:patient_id]
      @patient = @organization.patients.find(params[:patient_id])
    else
      redirect_to patients_path(slug: @organization.slug), alert: "Patient context missing."
    end
  end

  def encounter_params
    params.require(:encounter).permit(
      :patient_id,
      :visit_date,
      :provider_id,
      :subjective,
      :objective,
      vital_attributes: [
        :id,
        :height_inches, :weight_lbs, :bmi,
        :temp_f,
        :bp_systolic, :bp_diastolic,
        :heart_rate, :resp_rate, :o2_sat
      ],
      encounter_procedures_attributes: [ :id, :cpt_code_search_value, :charge_amount, :modifiers, :_destroy ],
      encounter_diagnoses_attributes: [ :id, :icd_code, :description, :_destroy ]
    )
  end
end
