redis_config = { url: ENV['REDIS_URL'] }

# if ['production', 'sandbox'].include?(Rails.env)
#   redis_config = {
#     url: ENV['REDIS_URL'],

#   }
# end

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end