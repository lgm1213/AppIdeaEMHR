module Admin
  class UsersController < Admin::BaseController
    before_action :set_organization, only: [ :new, :create, :index ]
    before_action :set_user, only: [ :show, :edit, :update, :destroy ]

    def index
      if @organization
        @users = @organization.users
      else
        @users = User.all.includes(:organization)
      end
    end

    def show
      # Renders app/views/admin/users/show.html.erb
    end

    def new
      @user = @organization.users.build
    end

    def create
      @user = @organization.users.build(user_params)
      @user.password ||= "Temporary123!"

      if @user.save
        redirect_to admin_organization_path(@organization), notice: "User created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      # Renders app/views/admin/users/edit.html.erb
    end

    def update
      if @user.update(user_params)
        # Redirect back to the organization they belong to
        redirect_to admin_organization_path(@user.organization), notice: "User details updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      org = @user.organization
      @user.destroy
      redirect_to admin_organization_path(org), notice: "User deleted."
    end

    private

    def set_organization
      if params[:organization_id]
        @organization = Organization.find(params[:organization_id])
      end
    end

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email_address, :role, :password, :password_confirmation)
    end
  end
end
