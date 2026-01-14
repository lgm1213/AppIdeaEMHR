class DashboardController < ApplicationController
  def index
    @user = Current.user
    @organization = @current_organization

    if @user.is_provider?
      @todays_appointments = @organization.appointments
                                          .where(provider_id: @user.provider.id)
                                          .where(start_time: Date.current.all_day)
                                          .includes(:patient)
                                          .order(:start_time)

      @my_recent_notes = @organization.encounters
                                      .where(provider_id: @user.provider.id)
                                      .includes(:patient)
                                      .order(created_at: :desc)
                                      .limit(5)
    else
      @patient_count = @organization.patients.count
      @provider_count = @organization.providers.count
      @total_notes = @organization.encounters.count

      @recent_activity = @organization.encounters.includes(:patient, :provider).order(created_at: :desc).limit(5)
      @new_patients = @organization.patients.order(created_at: :desc).limit(5)
    end
  end
end
