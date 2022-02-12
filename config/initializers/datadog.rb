Datadog.configure do |c|
  # Service name
  c.service = 'api'

  # Enable in production only
  c.tracer.enabled = ['production', 'sandbox'].include?(Rails.env)

  c.tracer sampler: Datadog::PrioritySampler.new(
    post_sampler: Datadog::Sampling::RuleSampler.new(
      [
        Datadog::Sampling::SimpleRule.new(service: 'o1061437.ingest.sentry.io', sample_rate: 0.0),
        Datadog::Sampling::SimpleRule.new(name: 'sidekiq.job_fetch', sample_rate: 0.05),
        Datadog::Sampling::SimpleRule.new(name: 'sidekiq.heartbeat', sample_rate: 0.05),
        Datadog::Sampling::SimpleRule.new(name: 'sidekiq.scheduled_push', sample_rate: 0.05),
        Datadog::Sampling::SimpleRule.new(name: 'BRPOP', sample_rate: 0.05),
        Datadog::Sampling::SimpleRule.new(name: 'SCARD', sample_rate: 0.05),
        Datadog::Sampling::SimpleRule.new(name: 'EVALSHA', sample_rate: 0.05),
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

  # Integrations

  # c.use :active_job,    service_name: 'worker'

  c.use :active_record,
    orm_service_name: 'orm',     # Service name used for the mapping portion of query results to ActiveRecord objects. Inherits service name from parent by default.
    service_name:     'database' # Service name used for database portion of active_record instrumentation.

  # c.use :aws,           service_name: 'aws'

  c.use :http, describes: /api\.stripe\.com/ do |http|
    http.service_name    = 'api.stripe.com'
    http.split_by_domain = false
  end

  c.use :http, describes: /(sandbox\.)?auth\.houseninja\.co/ do |http|
    http.service_name    = 'auth'
    http.split_by_domain = false
  end

  c.use :http, describes: /api\.hubapi\.com/ do |http|
    http.service_name    = 'api.hubapi.com'
    http.split_by_domain = false
  end

  c.use :http, split_by_domain: true

  c.use :rails,
    cache_service:       'cache',
    database_service:    'database',
    distributed_tracing: true,
    job_service:         'workers',
    service_name:        'api',
    log_injection:       true

  c.use :redis,
    service_name: 'redis'

  c.use :sidekiq,
    service_name: 'sidekiq',
    tag_args:     true
end

Datadog::Pipeline.before_flush(
  # Remove spans that are trafficked to sentry
  Datadog::Pipeline::SpanFilter.new { |span| span.get_tag('sevice') =~ /\.sentry\.io/ },
  Datadog::Pipeline::SpanFilter.new { |span| span.service =~ /\.sentry\.io/ }
)

Datadog::Pipeline.before_flush do |trace|
  trace.delete_if { |span| span.service =~ /\.sentry\.io/ }
end
