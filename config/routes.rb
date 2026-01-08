Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # Registration
  get "signup", to: "registrations#new"
  post "signup", to: "registrations#create"

  # Root route
  root "dashboard#index"

  # Dashboard
  get "dashboard", to: "dashboard#index"

  # Leads
  resources :leads do
    member do
      post :assign
      patch :mark_contacted
    end
    resources :communications, only: [:create]
  end

  # Tours
  resources :tours do
    resources :tour_departures, shallow: true
  end

  # Bookings
  resources :bookings do
    resources :payments, only: [:new, :create]
  end

  # Webhooks (no CSRF protection)
  namespace :webhooks do
    post :wazzup24
  end
end
