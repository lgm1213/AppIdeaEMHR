class CareTeamMembersController < ApplicationController
  before_action :set_patient

  def create
    @patient = Patient.find(params[:patient_id])

    # Initialize with safe params only (user_id, status)
    @care_team_member = @patient.care_team_members.new(care_team_member_params)

    # Manually assign the role
    if params[:care_team_member][:role].present?
      @care_team_member.role = params[:care_team_member][:role]
    end

    if @care_team_member.save
      redirect_to patient_path(@current_organization.slug, @patient), notice: "Member added."
    else
      redirect_to patient_path(@current_organization.slug, @patient), alert: "Could not add member."
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

  def care_team_member_params
    # STRICTLY permit only safe fields. Role is assigned manually above.
    params.require(:care_team_member).permit(:user_id, :status)
  end
end
