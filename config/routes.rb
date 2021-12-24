Rails.application.routes.draw do
  # Mounts
  mount OkComputer::Engine, at: '/health'           # Health Checks
  # mount Stripe::Engine,     at: '/webhooks/stripe'  # Stripe Webhooks
end
