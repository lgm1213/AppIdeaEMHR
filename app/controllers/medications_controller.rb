class MedicationsController < ApplicationController
  before_action :set_patient

  def create
    @medication = @patient.medications.build(medication_params)
    @medication.prescribed_by = Current.user
    @medication.status = "Active"

    if @medication.save
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), notice: "Medication prescribed."
    else
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), alert: "Error: #{@medication.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @medication = @patient.medications.find(params[:id])
    @medication.destroy
    redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), notice: "Medication removed."
  end

  def print
    pdf = PrescriptionGenerator.new(@medication).call

    send_data pdf,
              filename: "Rx_#{@patient.last_name}_#{@medication.name}_#{Date.today}.pdf",
              type: "application/pdf",
              disposition: "inline" # 'inline' opens in browser, 'attachment' downloads
  end

  private

  def set_patient
    @patient = Patient.find(params[:patient_id])
  end

  def medication_params
    params.require(:medication).permit(:name, :dosage, :frequency, :status, :sig, :quantity, :quantity_unit, :refills, :pharmacy_note)
  end
end
