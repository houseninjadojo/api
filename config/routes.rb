# == Route Map
#

Rails.application.routes.draw do
  # Mounts
  mount OkComputer::Engine, at: '/health'           # Health Checks
  # mount VandalUi::Engine,   at: '/vandal' if Rails.env.development?

  # webhooks
  post '/webhooks/arrivy',  to: 'webhooks#arrivy'
  post '/webhooks/hubspot', to: 'webhooks#hubspot'
  post '/webhooks/stripe',  to: 'webhooks#stripe'

  # api
  defaults format: :jsonapi do
    resources :common_requests,    path: 'common-requests',    only: [:index, :show]
    resources :devices,            path: 'devices',            only: [:index, :show, :create, :update]
    resources :documents,          path: 'documents',          only: [:index, :show, :create, :update, :destroy]
    resources :document_groups,    path: 'document-groups',    only: [:index, :show, :create, :update, :destroy]
    resources :estimates,          path: 'estimates',          only: [:index, :show, :update]
    resources :invoices,           path: 'invoices',           only: [:index, :show]
    resources :home_care_tips,     path: 'home-care-tips',     only: [:index, :show]
    resources :line_items,         path: 'line-items',         only: [:index, :show]
    resources :payment_methods,    path: 'payment-methods',    only: [:index, :show, :create, :update, :destroy]
    resources :payments,           path: 'payments',           only: [:index, :show, :create]
    resources :promo_codes,        path: 'promo-codes',        only: [:index, :show]
    resources :properties,         path: 'properties',         only: [:index, :show, :create, :update]
    resources :service_areas,      path: 'service-areas',      only: [:index, :show]
    resources :subscription_plans, path: 'subscription-plans', only: [:index, :show]
    resources :subscriptions,      path: 'subscriptions',      only: [:index, :show, :create, :destroy]
    resources :users,              path: 'users',              only: [:index, :show, :create, :update, :destroy]
    resources :work_orders,        path: 'work-orders',        only: [:index, :show, :create, :update]

    resources :resource_verifications, path: 'resource-verifications', only: [:create]

    root to: 'home#index'
  end

  # activestorage
  direct :cdn_asset do |model, options|
    expires_in = options.delete(:expires_in) { ActiveStorage.urls_expire_in }

    if model.respond_to?(:signed_id)
      route_for(
        :rails_service_blob_proxy,
        model.signed_id(expires_in: expires_in),
        model.filename,
        options.merge(host: Rails.settings.domains[:documents])
      )
    else
      signed_blob_id = model.blob.signed_id(expires_in: expires_in)
      variation_key  = model.variation.key
      filename       = model.blob.filename

      route_for(
        :rails_blob_representation_proxy,
        signed_blob_id,
        variation_key,
        filename,
        options.merge(host: Rails.settings.domains[:documents])
      )
    end
  end
end
