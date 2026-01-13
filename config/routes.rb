Rails.application.routes.draw do
  # Public & Auth
  root "pages#home"
  resource :session
  resources :passwords, param: :token

  # Public Sign Up
  get "signup", to: "registrations#new"
  post "signup", to: "registrations#create"

  # SuperAdmin Area
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

  # Tenant Area (The Clinical App)
  scope "/:slug" do
    get "dashboard", to: "dashboard#index", as: :practice_dashboard
    resources :facilities
    # resources :patients, etc...
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
