Rails.application.routes.draw do
  get "dashboard/index"
  resources :facilities
  resources :organizations
  resource :session
  resources :passwords, param: :token

  # The Public Landing Page (No login required)
  root "pages#home"

  # The Secure Application Area (Login required)
  get "dashboard", to: "dashboard#index", as: :dashboard

  get "up" => "rails/health#show", as: :rails_health_check
end
