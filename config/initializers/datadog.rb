Datadog.configure do |c|
  # Service name
  c.service = 'api'

  # Enable in production only
  c.tracing.enabled = ['production', 'sandbox'].include?(Rails.env)

  c.tracing.sampler = Datadog::Tracing::Sampling::PrioritySampler.new(
    post_sampler: Datadog::Tracing::Sampling::RuleSampler.new(
      [
        Datadog::Tracing::Sampling::SimpleRule.new(service: 'o1061437.ingest.sentry.io', sample_rate: 0.0),
        Datadog::Tracing::Sampling::SimpleRule.new(name: 'sidekiq.job_fetch', sample_rate: 0.01),
        Datadog::Tracing::Sampling::SimpleRule.new(name: 'sidekiq.heartbeat', sample_rate: 0.01),
        Datadog::Tracing::Sampling::SimpleRule.new(name: 'sidekiq.scheduled_push', sample_rate: 0.01),
        Datadog::Tracing::Sampling::SimpleRule.new(name: 'sidekiq.scheduled_poller_wait', sample_rate: 0.01),
        Datadog::Tracing::Sampling::SimpleRule.new(name: 'BRPOP', sample_rate: 0.01),
        Datadog::Tracing::Sampling::SimpleRule.new(name: 'SCARD', sample_rate: 0.01),
        Datadog::Tracing::Sampling::SimpleRule.new(name: 'EVALSHA', sample_rate: 0.01),
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
    'git': {
      'repository_url': 'github.com/houseninjadojo/api',
      'commit': { 'sha': ENV["HEROKU_SLUG_COMMIT"] },
    }
  }
  c.version = ENV['HEROKU_SLUG_COMMIT']

  # Logging
  c.tracing.log_injection = true
  c.diagnostics.startup_logs.enabled = true

  # Integrations

  # c.tracing.instrument :action_pack,
  #   service_name: 'controllers'
  c.tracing.instrument :action_mailer,
    service_name: 'mailers',
    email_data: true

  c.tracing.instrument :active_job,
    service_name: 'workers'

  # c.tracing.instrument :active_record,
  #   orm_service_name: 'orm',     # Service name used for the mapping portion of query results to ActiveRecord objects. Inherits service name from parent by default.
  #   service_name:     'database' # Service name used for database portion of active_record instrumentation.

  c.tracing.instrument :active_support,
    service_name: 'cache'

  c.tracing.instrument :aws,
    service_name: 'aws'

  c.tracing.instrument :faraday, describes: /(fcm|www)\.googleapis\.com/ do |faraday|
    faraday.service_name = 'firebase'
    faraday.split_by_domain = false
  end

  c.tracing.instrument :http, describes: /((app|api)\.)?arrivy\.com/ do |http|
    http.service_name    = 'arrivy'
    http.split_by_domain = false
  end
  c.tracing.instrument :http, describes: /((sandbox\.)?auth\.houseninja\.co)|houseninja\.us\.auth0\.com/ do |http|
    http.service_name    = 'auth0'
    http.split_by_domain = false
  end
  c.tracing.instrument :http, describes: /s3\.amazonaws\.com/ do |http|
    http.service_name    = 'aws'
    http.split_by_domain = false
  end
  c.tracing.instrument :http, describes: /api[\d]{0,2}\.branch.io/ do |http|
    http.service_name    = 'branch'
    http.split_by_domain = false
  end
  c.tracing.instrument :http, describes: /www\.cloudflare\.com/ do |http|
    http.service_name    = 'cloudflare'
    http.split_by_domain = false
  end
  # c.tracing.instrument :http, describes: /(fcm|www)\.googleapis\.com/ do |http|
  #   http.service_name = 'firebase'
  #   http.split_by_domain = false
  # end
  c.tracing.instrument :http, describes: /((\w*\.)*hubapi\.com)|hubspotusercontent-\w+\.net/ do |http|
    http.service_name    = 'hubspot'
    http.split_by_domain = false
  end
  c.tracing.instrument :http, describes: /api\.intercom.com/ do |http|
    http.service_name    = 'intercom'
    http.split_by_domain = false
  end
  c.tracing.instrument :http, describes: /(api)?\.sendgrid.com/ do |http|
    http.service_name    = 'sendgrid'
    http.split_by_domain = false
  end
  c.tracing.instrument :http, describes: /((\w*\.)*stripe\.com)|stripe-upload-api\.s3\.us-west-1\.amazonaws\.com/ do |http|
    http.service_name    = 'stripe'
    http.split_by_domain = false
  end
  c.tracing.instrument :http, split_by_domain: true

  c.tracing.instrument :rack,
    headers: {
      request: ['X-Request-ID', 'Host', 'Content-Type'],
      response: ['X-Request-ID', 'Content-Type']
    }

  c.tracing.instrument :rails,
    distributed_tracing: true,
    request_queuing:     false,
    service_name:        'api'

  c.tracing.instrument :pg,
    service_name:        'database',
    comment_propagation: 'service'

  c.tracing.instrument :redis,
    service_name: 'redis'

  c.tracing.instrument :sidekiq,
    service_name: 'sidekiq',
    tag_args:     true

  # List of header formats that should be extracted
  c.tracing.distributed_tracing.propagation_extract_style = [
    Datadog::Tracing::Configuration::Ext::Distributed::PROPAGATION_STYLE_DATADOG,
    # Datadog::Tracing::Configuration::Ext::Distributed::PROPAGATION_STYLE_B3,
    # Datadog::Tracing::Configuration::Ext::Distributed::PROPAGATION_STYLE_B3_SINGLE_HEADER
  ]
end

Datadog::Tracing.before_flush(
  # Remove spans that are trafficked to sentry
  Datadog::Tracing::Pipeline::SpanFilter.new { |span| span.get_tag('sevice') =~ /\.sentry\.io/ },
  Datadog::Tracing::Pipeline::SpanFilter.new { |span| span.service =~ /\.sentry\.io/ },
  Datadog::Tracing::Pipeline::SpanProcessor.new { |span| span&.http&.url&.gsub!(/\/work\-orders\/[\w\%]+\-\-[\w\%\-\?]+/, '/work-orders/[REDACTED]?include') }
)

# Datadog::Tracing.before_flush do |trace|
#   trace.delete_if { |span| span.service =~ /\.sentry\.io/ }
# end
