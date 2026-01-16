class CareTeamMembersController < ApplicationController
  before_action :set_patient

  def create
    @member = @patient.care_team_members.new(member_params)

    if @member.save
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id), notice: "Team member added."
    else
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id), alert: "Error: #{@member.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @member = @patient.care_team_members.find(params[:id])
    @member.destroy
    redirect_to patient_path(slug: @current_organization.slug, id: @patient.id), notice: "Team member removed."
  end

  private

  def set_patient
    @patient = Patient.find(params[:patient_id])
  end

  def member_params
    params.require(:care_team_member).permit(:user_id, :role, :status)
  end
end
