Kredis::Connections.connections[:shared] = Redis.new(
  url: ENV['REDIS_URL'],
  timeout: 2,
  reconnect_attempts: 3,
  ssl_params: {
    verify_mode: OpenSSL::SSL::VERIFY_NONE,
  }
)
