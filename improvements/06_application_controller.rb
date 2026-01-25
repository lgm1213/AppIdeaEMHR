# frozen_string_literal: true

# ==============================================================================
# IMPROVEMENT #6: Stricter Tenant Authorization in ApplicationController
# ==============================================================================
# File: app/controllers/application_controller.rb
#
# Changes:
# - Stricter authorize_tenant! that doesn't allow nil user to pass
# - Added set_current_organization for Current attributes
# - Added helper methods for organization context
# - Better error handling and logging
# ==============================================================================

class ApplicationController < ActionController::Base
  include Authentication

  allow_browser versions: :modern

  before_action :require_authentication
  before_action :authorize_tenant!, if: -> { params[:slug].present? }
  before_action :set_current_organization, if: -> { @current_organization.present? }

  # PaperTrail Audit Log
  before_action :set_paper_trail_whodunnit

  # Make organization available to views
  helper_method :current_organization, :current_organization?

  def default_url_options
    { slug: params[:slug] || @current_organization&.slug }
  end

  private

  # ===========================================================================
  # Tenant Authorization
  # ===========================================================================
  def authorize_tenant!
    @current_organization = Organization.find_by!(slug: params[:slug])

    # STRICT CHECK: User MUST be logged in AND belong to this organization
    # This prevents any edge cases where a nil user might slip through
    unless Current.user.present? && Current.user.organization_id == @current_organization.id
      log_unauthorized_access_attempt
      redirect_to root_path, alert: "You are not authorized to access this practice."
      return false
    end

    true
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn("[TenantAuth] Attempted access to non-existent org: slug=#{params[:slug]}")
    redirect_to root_path, alert: "Practice not found."
    false
  end

  # ===========================================================================
  # Current Organization Setup
  # ===========================================================================
  def set_current_organization
    # Make organization available via Current for models/services
    Current.organization = @current_organization if defined?(Current) && Current.respond_to?(:organization=)
  end

  def current_organization
    @current_organization
  end

  def current_organization?
    @current_organization.present?
  end

  # ===========================================================================
  # PaperTrail
  # ===========================================================================
  def user_for_paper_trail
    Current.user&.id
  end

  # Additional PaperTrail context (optional but useful)
  def info_for_paper_trail
    {
      ip_address: request.remote_ip,
      user_agent: request.user_agent&.truncate(255),
      organization_id: @current_organization&.id
    }
  end

  # ===========================================================================
  # Security Logging
  # ===========================================================================
  def log_unauthorized_access_attempt
    Rails.logger.warn(
      "[TenantAuth] Unauthorized access attempt: " \
      "user_id=#{Current.user&.id}, " \
      "user_org=#{Current.user&.organization_id}, " \
      "requested_org=#{@current_organization&.id}, " \
      "slug=#{params[:slug]}, " \
      "path=#{request.path}, " \
      "ip=#{request.remote_ip}"
    )
  end

  # ===========================================================================
  # Error Handling (Optional - uncomment if you want custom error pages)
  # ===========================================================================
  # rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  # rescue_from ActionController::RoutingError, with: :route_not_found
  #
  # def record_not_found
  #   respond_to do |format|
  #     format.html { render "errors/not_found", status: :not_found }
  #     format.json { render json: { error: "Record not found" }, status: :not_found }
  #   end
  # end
  #
  # def route_not_found
  #   respond_to do |format|
  #     format.html { render "errors/not_found", status: :not_found }
  #     format.json { render json: { error: "Route not found" }, status: :not_found }
  #   end
  # end
end
