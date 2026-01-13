class ProvidersController < ApplicationController
  before_action :set_provider, only: %i[ show edit update destroy ]

  def index
    @providers = @current_organization.providers.includes(:user)
  end

  def show
  end

  def new
    @user = @current_organization.users.build
    @user.build_provider
  end

  def create
    @user = @current_organization.users.build(user_params)

    @user.role = :provider
    @user.provider.organization = @current_organization

    if @user.save
      redirect_to providers_path(slug: @current_organization.slug), notice: "Dr. #{@user.last_name} has been successfully onboarded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = @provider.user
  end

  def update
    @user = @provider.user

    if @user.update(user_params)
      redirect_to providers_path(slug: @current_organization.slug), notice: "Provider details updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    user = @provider.user
    user.destroy
    redirect_to providers_path(slug: @current_organization.slug), notice: "Provider account removed."
  end

  private

  def set_provider
    # We find the provider by ID (from the URL /providers/:id)
    @provider = @current_organization.providers.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email_address, :password, :password_confirmation,
      # id is added to provider_attributes so Rails knows which record to update
      provider_attributes: [ :id, :npi, :license_number, :dea_number, :specialty ]
    )
  end
end
