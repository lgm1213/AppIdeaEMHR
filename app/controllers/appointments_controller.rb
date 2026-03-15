# frozen_string_literal: true

class AppointmentsController < ApplicationController
  before_action :set_appointment, only: %i[show edit update cancel]

  # GET /:slug/appointments
  def index
    # Determine the Date Context
    @target_date = params[:date] ? Date.parse(params[:date]) : Date.current
    @start_of_week = @target_date.beginning_of_week(:monday)
    @end_of_week   = @target_date.end_of_week(:friday)

    # Fetches the agenda data
    @days_appointments = @current_organization.appointments
                                              .where(start_time: @target_date.all_day)
                                              .includes(:patient, :provider)
                                              .order(:start_time)

    # Fetches the calendar data and pre-groups by date to avoid N+1 view iteration
    @weeks_appointments  = @current_organization.appointments
                                                .where(start_time: @start_of_week.beginning_of_day..@end_of_week.end_of_day)
                                                .includes(:patient, :provider)
    @appointments_by_date = @weeks_appointments.group_by { |a| a.start_time.to_date }
  end

  def show
  end

  def new
    @appointment = @current_organization.appointments.build
    @appointment.start_time = Time.current.beginning_of_hour + 1.hour
    @appointment.end_time   = @appointment.start_time + 30.minutes
    @appointment.patient_id = params[:patient_id] if params[:patient_id]

    @allowed_statuses = Appointment.statuses.keys.map { |s| [ s.humanize, s ] }
  end

  def create
    @appointment = @current_organization.appointments.build(appointment_params)

    if @appointment.save
      redirect_to appointments_path(slug: @current_organization.slug, date: @appointment.start_time.to_date),
                  notice: "Appointment scheduled."
    else
      @allowed_statuses = Appointment.statuses.keys.map { |s| [ s.humanize, s ] }
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @allowed_statuses = allowed_statuses_for(@appointment.status.to_sym)
  end

  def update
    if @appointment.update(appointment_params)
      redirect_to appointments_path(slug: @current_organization.slug, date: @appointment.start_time.to_date),
                  notice: "Appointment updated."
    else
      @allowed_statuses = allowed_statuses_for(@appointment.status_was.to_sym)
      render :edit, status: :unprocessable_entity
    end
  end

  # PATCH /:slug/appointments/:id/cancel
  # Soft-cancels an appointment via the state machine instead of hard-deleting.
  def cancel
    unless @appointment.can_cancel?
      redirect_to appointment_path(slug: @current_organization.slug, id: @appointment.id),
                  alert: "This appointment cannot be cancelled."
      return
    end

    @appointment.update!(status: :cancelled)
    redirect_to appointments_path(slug: @current_organization.slug, date: @appointment.start_time.to_date),
                notice: "Appointment cancelled."
  end

  private

  def set_appointment
    @appointment = @current_organization.appointments.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:patient_id, :provider_id, :start_time, :end_time, :status, :reason)
  end

  # Builds the context-aware status list for the form dropdown.
  # Always includes the current status so the form renders correctly,
  # then adds only the valid forward transitions from the state machine.
  def allowed_statuses_for(status_sym)
    transitions = Appointment::VALID_TRANSITIONS[status_sym] || []
    ([ status_sym ] + transitions).map { |s| [ s.to_s.humanize, s.to_s ] }
  end
end
