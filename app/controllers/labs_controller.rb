class LabsController < ApplicationController
  before_action :set_patient

  def create
    @lab = @patient.labs.new(lab_params)
    if @lab.save
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), notice: "Lab order added."
    else
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), alert: "Error adding Lab."
    end
  end

  def destroy
    @patient.labs.find(params[:id]).destroy
    redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), notice: "Lab removed."
  end

  private

  def set_patient
    @patient = Patient.find(params[:patient_id])
  end

  def lab_params
    params.require(:lab).permit(:test_type, :result, :status, :date)
  end
end
