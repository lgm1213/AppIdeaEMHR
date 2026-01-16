class DashboardController < ApplicationController
  def index
    @user = Current.user
    @organization = @current_organization

    if @user.is_provider? && @user.provider.present?
      # Provider's current(today's) schedule
      @todays_appointments = @organization.appointments
                                          .where(provider_id: @user.provider.id)
                                          .where(start_time: Time.current.beginning_of_day..Time.current.end_of_day)
                                          .includes(:patient)
                                          .order(:start_time)

      # Recent Patients edited by this provider
      @recent_patients = @organization.patients
                                      .order(updated_at: :desc)
                                      .limit(5)

      # Pending Labs (For the yellow alert box)
      @pending_labs = Lab.where(patient_id: @organization.patients.select(:id))
                         .where(status: "Pending")
                         .order(date: :desc)
                         .limit(5)
    else
      # ADMIN / STAFF VIEW
      @patient_count = @organization.patients.count
      @provider_count = @organization.providers.count
      @total_notes = @organization.encounters.count
      @recent_activity = @organization.encounters.includes(:patient, :provider).order(created_at: :desc).limit(5)
      @new_patients = @organization.patients.order(created_at: :desc).limit(5)
    end
  end
end
