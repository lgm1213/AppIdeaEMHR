class ApplicationController < ActionController::Base
  include Authentication
  allow_browser versions: :modern

  before_action :require_authentication
  before_action :authorize_tenant!, if: -> { params[:slug].present? }
  before_action :set_paper_trail_whodunnit

  def default_url_options
    { slug: params[:slug] || @current_organization&.slug }
  end

  private

  def authorize_tenant!
    @current_organization = Organization.find_by!(slug: params[:slug])

    return unless Current.user

    unless Current.user.organization_id == @current_organization.id
      redirect_to root_path(slug: nil), alert: "You are not authorized to access this practice."
    end

  rescue ActiveRecord::RecordNotFound
    redirect_to root_path(slug: nil), alert: "Practice not found."
  end

  def user_for_paper_trail
    Current.user&.id
  end
end
