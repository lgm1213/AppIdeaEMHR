class ConditionsController < ApplicationController
  before_action :set_patient

  def create
    @condition = @patient.conditions.new(condition_params)

    if @condition.save
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), notice: "Condition added."
    else
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), alert: "Failed to add condition: #{@condition.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @condition = @patient.conditions.find(params[:id])
    @condition.destroy
    redirect_to patient_path(slug: @current_organization.slug, id: @patient.id, tab: "clinical"), notice: "Condition removed."
  end

  private

  def set_patient
    @patient = Patient.find(params[:patient_id])
  end

  def condition_params
    params.require(:condition).permit(:name, :icd10_code, :onset_date, :status)
  end
end
