Rails.application.routes.draw do
  # Public & Auth
  root "pages#home"
  resource :session
  resources :passwords, param: :token
  get "up" => "rails/health#show", as: :rails_health_check

  # SUPER ADMIN AREA
  namespace :admin do
    root to: "dashboard#index" # Optional: a main stats page

    resources :organizations do
      # This allows drilling down: /admin/organizations/1/facilities
      resources :facilities, only: [ :index ]
      resources :users, only: [ :index ]
    end

    # Global lists (optional, if you want to search ALL users across the DB)
    resources :users, only: [ :index, :show, :edit, :update ]
  end

  # TENANT AREA (The Clinical App)
  scope "/:slug" do
    get "dashboard", to: "dashboard#index", as: :practice_dashboard
    resources :facilities
    # resources :patients, etc...
  end
end
