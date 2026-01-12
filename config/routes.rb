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

  # Communications - Edit and delete WhatsApp messages
  resources :communications, only: [:edit, :update, :destroy]

  # Clients - Central hub for customer management
  resources :clients do
    resources :leads, only: [:new, :create]
    resources :bookings, only: [:new, :create]
    resources :communications, only: [:create]
  end

  # Leads - Can also be created standalone or from clients
  resources :leads do
    member do
      post :assign
      patch :mark_contacted
      post :convert_to_booking
    end
    resources :communications, only: [:create]
  end

  # Tours and Departures
  resources :tours do
    resources :tour_departures, shallow: true
  end

  # Bookings - Can be created from leads or clients
  resources :bookings do
    member do
      patch :confirm
      patch :cancel
    end
    resources :payments, only: [:new, :create, :show]
    resources :communications, only: [:create]
  end

  # Payments (accessible via bookings)
  resources :payments, only: [:index, :show, :edit, :update]

  # WhatsApp Templates
  resources :whatsapp_templates do
    member do
      patch :toggle_active
    end
  end

  # Settings
  get 'settings', to: 'settings#index', as: :settings
  get 'settings/whatsapp_channels', to: 'settings#whatsapp_channels', as: :whatsapp_channels_settings
  post 'settings/refresh_channels', to: 'settings#refresh_channels', as: :refresh_channels_settings

  # Webhooks (no CSRF protection)
  namespace :webhooks do
    post :wazzup24
  end
end
