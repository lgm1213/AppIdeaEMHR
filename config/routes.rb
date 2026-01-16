Rails.application.routes.draw do
  # Public & Authentication Routes
  root "pages#home"
  resource :session
  resources :passwords, param: :token

  # Registration Routes
  get "signup", to: "registrations#new"
  post "signup", to: "registrations#create"

  # SuperAdmin Routes
  namespace :admin do
    root to: "dashboard#index"

    resources :organizations do
      resources :facilities, only: [ :index, :new, :create, :show, :edit, :update ]
      resources :users, only: [ :index, :new, :create ]
    end

    resources :users, only: [ :index, :show, :edit, :update ]
  end

  # Tenant Area Routes (The Clinical App)
  scope "/:slug" do
    # The main hub for the clinic
    get "dashboard", to: "dashboard#index", as: :practice_dashboard

    resources :facilities
    resources :providers

    # Schedule
    resources :appointments

    # Clinical Records
    resources :patients do
      resources :encounters
      resources :documents
      # Discrete Clinical Data
      resources :allergies, only: [ :create, :destroy ]
      resources :conditions, only: [ :create, :destroy ]
      resources :medications, only: [ :create, :destroy ]
      resources :dmes, only: [ :create, :destroy ]
      resources :labs, only: [ :create, :destroy ]
      # Care Team Management
      resources :care_team_members, only: [ :create, :destroy ]
    end
  end

  # System Health Check
  get "up" => "rails/health#show", as: :rails_health_check
end
