# == Route Map
#

Rails.application.routes.draw do
  # Mounts
  mount OkComputer::Engine, at: '/health'           # Health Checks
  # mount Stripe::Engine,     at: '/webhooks/stripe'  # Stripe Webhooks

  defaults format: :jsonapi do
    resources :addresses,          path: 'addresses',          only: [:index, :show, :create, :update]
    resources :common_requests,    path: 'common-requests',    only: [:index, :show]
    resources :devices,            path: 'devices',            only: [:index, :show, :create, :update]
    resources :home_care_tips,     path: 'home-care-tips',     only: [:index, :show]
    resources :payment_methods,    path: 'payment-methods',    only: [:index, :show, :create, :update, :destroy]
    resources :properties,         path: 'properties',         only: [:index, :show, :create, :update]
    resources :service_areas,      path: 'service-areas',      only: [:index, :show]
    resources :subscription_plans, path: 'subscription-plans', only: [:index, :show]
    resources :users,              path: 'users',              only: [:index, :show, :create, :update]
    resources :work_orders,        path: 'work-orders',        only: [:index, :show, :create, :update]

    root to: 'home#index'
  end
end
