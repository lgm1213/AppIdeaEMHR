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

    # Assign System Role
    @user.role = :provider

    # Assign Tenant to the Provider Profile Use safe navigation in case build_provider failed
    @user.provider ||= @user.build_provider
    @user.provider.organization = @current_organization

    # Set Default Password (Critical for "Add Staff" flow) If the form didn't pass a password, we set a temp one so validation passes.
    @user.password ||= "password"

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
    @provider = @current_organization.providers.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email_address, :password, :password_confirmation,
      provider_attributes: [ :id, :npi, :license_number, :dea_number, :specialty ]
    )
  end
end
