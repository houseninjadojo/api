# == Route Map
#

Rails.application.routes.draw do
  # Mounts
  mount OkComputer::Engine, at: '/health'           # Health Checks
  # mount Stripe::Engine,     at: '/webhooks/stripe'  # Stripe Webhooks

  defaults format: :jsonapi do
    resources :addresses
    resources :common_requests, path: 'common-requests', only: [:index, :show]
    resources :devices
    resources :properties
    resources :users
    resources :payment_methods, path: 'payment-methods'
    resources :work_orders, path: 'work-orders'

    root to: 'home#index'
  end
end
