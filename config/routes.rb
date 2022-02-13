# == Route Map
#

Rails.application.routes.draw do
  # Mounts
  mount OkComputer::Engine, at: '/health'           # Health Checks
  # mount VandalUi::Engine,   at: '/vandal' if Rails.env.development?

  # webhooks
  post '/webhooks/hubspot', to: 'webhooks#hubspot'
  post '/webhooks/stripe',  to: 'webhooks#stripe'

  # api
  defaults format: :jsonapi do
    resources :common_requests,    path: 'common-requests',    only: [:index, :show]
    resources :devices,            path: 'devices',            only: [:index, :show, :create, :update]
    resources :documents,          path: 'documents',          only: [:index, :show]
    resources :invoices,           path: 'invoices',           only: [:index, :show]
    resources :home_care_tips,     path: 'home-care-tips',     only: [:index, :show]
    resources :payment_methods,    path: 'payment-methods',    only: [:index, :show, :create, :update, :destroy]
    resources :payments,           path: 'payments',           only: [:index, :show]
    resources :promo_codes,        path: 'promo-codes',        only: [:index, :show]
    resources :properties,         path: 'properties',         only: [:index, :show, :create, :update]
    resources :service_areas,      path: 'service-areas',      only: [:index, :show]
    resources :subscription_plans, path: 'subscription-plans', only: [:index, :show]
    resources :subscriptions,      path: 'subscriptions',      only: [:index, :show, :create]
    resources :users,              path: 'users',              only: [:index, :show, :create, :update]
    resources :work_orders,        path: 'work-orders',        only: [:index, :show, :create, :update]

    root to: 'home#index'
  end
end
