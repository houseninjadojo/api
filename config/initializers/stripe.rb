require 'stripe'

# Stripe Configuration

Stripe.api_key = Rails.secrets.dig(:stripe, :secret_key)
Stripe.proxy   = Rails.secrets.dig(:vgs, :outbound, :proxy_url)
Stripe.ca_bundle_path = Rails.secrets.dig(:vgs, :outbound, :ssl_cert)

if Rails.env.production?
  Stripe.log_level = Stripe::LEVEL_INFO
end

# @todo
# instrument this
#
# Stripe::Instrumentation.subscribe(:request_begin) do |request_event|
#   tags = {
#     method: request_event.method,
#     resource: request_event.path.split('/')[2],
#     code: request_event.http_status,
#     retries: request_event.num_retries
#   }
#   StatsD.distribution('stripe_request', request_event.duration, tags: tags)
# end
#
# Stripe::Instrumentation.subscribe(:request_end) do |request_event|
#   tags = {
#     method: request_event.method,
#     resource: request_event.path.split('/')[2],
#     code: request_event.http_status,
#     retries: request_event.num_retries
#   }
#   StatsD.distribution('stripe_request', request_event.duration, tags: tags)
# end
