if Rails.env.production?
  redis_config = {
    url: ENV['REDIS_URL'],
    verify_mode: OpenSSL::SSL::VERIFY_NONE,
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
