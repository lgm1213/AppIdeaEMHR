class AllergiesController < ApplicationController
  before_action :set_patient

  def create
    @allergy = @patient.allergies.new(allergy_params)

    if @allergy.save
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), notice: "Allergy added."
    else
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), alert: "Failed to add allergy: #{@allergy.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @allergy = @patient.allergies.find(params[:id])
    @allergy.destroy
    redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), notice: "Allergy removed."
  end

  private

  def set_patient
    @patient = Patient.find(params[:patient_id])
  end

  def allergy_params
    params.require(:allergy).permit(:name, :reaction, :severity, :status)
  end
end
