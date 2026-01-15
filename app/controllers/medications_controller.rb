class MedicationsController < ApplicationController
  before_action :set_patient

  def create
    @medication = @patient.medications.new(medication_params)

    if @medication.save
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), notice: "Medication added."
    else
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), alert: "Failed to add medication: #{@medication.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @medication = @patient.medications.find(params[:id])
    @medication.destroy
    redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), notice: "Medication removed."
  end

  private

  def set_patient
    @patient = Patient.find(params[:patient_id])
  end

  def medication_params
    params.require(:medication).permit(:name, :dosage, :frequency, :status)
  end
end
