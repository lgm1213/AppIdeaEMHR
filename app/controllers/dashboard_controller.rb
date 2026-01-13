class DashboardController < ApplicationController
  def index
    @user = Current.user

    @organization = @current_organization

    # Stats for the top cards
    @patient_count = @organization.patients.count
    @provider_count = @organization.providers.count

    # Recent Clinical Notes (The Feed) We use .includes to load patient/provider names in 1 query (prevent N+1 performance issues)
    @recent_encounters = @organization.encounters
                                      .includes(:patient, :provider)
                                      .order(visit_date: :desc)
                                      .limit(5)

    # Newest Patients (Right Sidebar)
    @recent_patients = @organization.patients
                                    .order(created_at: :desc)
                                    .limit(5)

    # Facilities (Preserving your original logic)
    @facilities = @organization.facilities
  end
end
