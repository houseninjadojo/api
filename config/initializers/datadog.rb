Datadog.configure do |c|
  # Service name
  c.service = 'api'

  # Enable in production only
  c.tracing.enabled = ['production', 'sandbox'].include?(Rails.env)

  c.tracing.sampler = Datadog::Tracing::Sampling::PrioritySampler.new(
    post_sampler: Datadog::Tracing::Sampling::RuleSampler.new(
      [
        Datadog::Tracing::Sampling::SimpleRule.new(service: 'o1061437.ingest.sentry.io', sample_rate: 0.0),
        Datadog::Tracing::Sampling::SimpleRule.new(name: 'sidekiq.job_fetch', sample_rate: 0.05),
        Datadog::Tracing::Sampling::SimpleRule.new(name: 'sidekiq.heartbeat', sample_rate: 0.05),
        Datadog::Tracing::Sampling::SimpleRule.new(name: 'sidekiq.scheduled_push', sample_rate: 0.05),
        Datadog::Tracing::Sampling::SimpleRule.new(name: 'BRPOP', sample_rate: 0.05),
        Datadog::Tracing::Sampling::SimpleRule.new(name: 'SCARD', sample_rate: 0.05),
        Datadog::Tracing::Sampling::SimpleRule.new(name: 'EVALSHA', sample_rate: 0.05),
      ]
    )
  )

  # Misc
  # c.partial_flush.enabled = true
  c.env = Rails.env.to_s
  c.tags = {
    'org': ENV["NAMESPACE_ORG"] || 'houseninja',
    'env': ENV["NAMESPACE_ENV"] || Rails.env.to_s,
    'service': ENV["NAMESPACE_SERVICE"] || 'api',
    'resource': ENV["NAMESPACE_RESOURCE"] || 'app',
  }
  c.version = ENV['HEROKU_SLUG_COMMIT']

  # Logging
  c.tracing.log_injection = true

  # Integrations

  # c.tracing.instrument :action_pack,
  #   service_name: 'controllers'

  c.tracing.instrument :active_job,
    service_name: 'workers'

  c.tracing.instrument :active_record,
    orm_service_name: 'orm',     # Service name used for the mapping portion of query results to ActiveRecord objects. Inherits service name from parent by default.
    service_name:     'database' # Service name used for database portion of active_record instrumentation.

  c.tracing.instrument :active_support,
    service_name: 'cache'

  c.tracing.instrument :aws,
    service_name: 'aws'

  c.tracing.instrument :http, describes: /api\.stripe\.com/ do |http|
    http.service_name    = 'api.stripe.com'
    http.split_by_domain = false
  end
  c.tracing.instrument :http, describes: /(sandbox\.)?auth\.houseninja\.co/ do |http|
    http.service_name    = 'auth'
    http.split_by_domain = false
  end
  c.tracing.instrument :http, describes: /api\.hubapi\.com/ do |http|
    http.service_name    = 'api.hubapi.com'
    http.split_by_domain = false
  end
  c.tracing.instrument :http, split_by_domain: true

  c.tracing.instrument :rails,
    distributed_tracing: true,
    service_name:        'api'

  c.tracing.instrument :redis,
    service_name: 'redis'

  c.tracing.instrument :sidekiq,
    service_name: 'sidekiq',
    tag_args:     true
end

Datadog::Tracing.before_flush(
  # Remove spans that are trafficked to sentry
  Datadog::Tracing::Pipeline::SpanFilter.new { |span| span.get_tag('sevice') =~ /\.sentry\.io/ },
  Datadog::Tracing::Pipeline::SpanFilter.new { |span| span.service =~ /\.sentry\.io/ }
)

Datadog::Tracing.before_flush do |trace|
  trace.delete_if { |span| span.service =~ /\.sentry\.io/ }
end
