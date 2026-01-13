module Admin
  class UsersController < Admin::BaseController
    def index
      # Eager load organization to prevent N+1 queries (performance)
      @users = User.includes(:organization).order(created_at: :desc)
    end
  end
end
