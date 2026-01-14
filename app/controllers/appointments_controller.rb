class AppointmentsController < ApplicationController
  before_action :set_appointment, only: %i[ show edit update destroy ]

  # GET /:slug/appointments
  def index
    # Determine the Date Context
    @target_date = params[:date] ? Date.parse(params[:date]) : Date.current
    @start_of_week = @target_date.beginning_of_week(:monday)
    @end_of_week = @target_date.end_of_week(:friday)

    # Fetchs the agenda data
    @days_appointments = @current_organization.appointments
                                              .where(start_time: @target_date.all_day)
                                              .includes(:patient, :provider)
                                              .order(:start_time)

    # Fetchs the calendar data
    @weeks_appointments = @current_organization.appointments
                                               .where(start_time: @start_of_week.beginning_of_day..@end_of_week.end_of_day)
                                               .includes(:patient, :provider)
  end

  def show
  end

  def new
    @appointment = @current_organization.appointments.build

    # Defaults
    @appointment.start_time = Time.current.beginning_of_hour + 1.hour
    @appointment.end_time = @appointment.start_time + 30.minutes

    # Pre-fill patient if passed in URL
    if params[:patient_id]
      @appointment.patient_id = params[:patient_id]
    end
  end

  def create
    @appointment = @current_organization.appointments.build(appointment_params)
    # Ensure status is set
    @appointment.status ||= :scheduled

    if @appointment.save
      redirect_to appointments_path(slug: @current_organization.slug, date: @appointment.start_time.to_date), notice: "Appointment scheduled."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @appointment.update(appointment_params)
      redirect_to appointments_path(slug: @current_organization.slug, date: @appointment.start_time.to_date), notice: "Appointment updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    date = @appointment.start_time.to_date
    @appointment.destroy
    redirect_to appointments_path(slug: @current_organization.slug, date: date), notice: "Appointment cancelled."
  end

  private

  def set_appointment
    @appointment = @current_organization.appointments.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:patient_id, :provider_id, :start_time, :end_time, :status, :reason)
  end
end
