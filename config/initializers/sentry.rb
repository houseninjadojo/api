Sentry.init do |config|
  config.dsn = Rails.secrets.dig(:sentry, :dsn)
  config.breadcrumbs_logger = [
    :monotonic_active_support_logger,
    :http_logger,
    :redis_logger
  ]

  config.environment = ENV['NAMESPACE_ENV']
  config.release     = ENV['HEROKU_SLUG_COMMIT']

  config.enabled_environments = %w(production sandbox)

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 1.0

  # strip unecessary attributes from breadcrumbs
  config.before_breadcrumb = lambda do |breadcrumb, _|
    if breadcrumb.data.include?(:datadog_span)
      breadcrumb.data.delete(:datadog_span)
    end
    breadcrumb
  end
end
