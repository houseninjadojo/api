# == Route Map
#

Rails.application.routes.draw do
  # Mounts
  mount OkComputer::Engine, at: '/health'           # Health Checks
  # mount Stripe::Engine,     at: '/webhooks/stripe'  # Stripe Webhooks

  defaults format: :jsonapi do
    resources :users
    resources :properties
    resources :addresses

    root to: 'home#index'
  end
end
