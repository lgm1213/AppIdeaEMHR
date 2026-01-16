class DmesController < ApplicationController
  before_action :set_patient

  def create
    @dme = @patient.dmes.new(dme_params)
    if @dme.save
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), notice: "DME added."
    else
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), alert: "Error adding DME."
    end
  end

  def destroy
    @patient.dmes.find(params[:id]).destroy
    redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), notice: "DME removed."
  end

  private

  def set_patient
    @patient = Patient.find(params[:patient_id])
  end

  def dme_params
    params.require(:dme).permit(:name, :status, :prescribed_date)
  end
end
