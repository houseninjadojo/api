if Rails.env.production? || Rails.env.sandbox?
  redis_config = {
    url: ENV['REDIS_URL'],
    # ssl_params: {
    #   verify_mode: OpenSSL::SSL::VERIFY_NONE
    # },
  }
else
  redis_config = {
    url: ENV['REDIS_URL'],
  }
end

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
