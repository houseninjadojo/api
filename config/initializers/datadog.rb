Datadog.configure do |c|
  # Service name
  c.service = 'api'

  # Enable in production only
  c.tracer.enabled = ['production', 'sandbox'].include?(Rails.env)
  # c.tracer.enabled = true

  # Misc
  # c.partial_flush.enabled = true
  c.env = Rails.env.to_s
  c.tags = {
    'org': ENV["NAMESPACE_ORG"] || 'houseninja',
    'env': ENV["NAMESPACE_ENV"] || Rails.env.to_s,
    'service': ENV["NAMESPACE_SERVICE"] || 'api',
    'resource': ENV["NAMESPACE_RESOURCE"] || 'app',
  }

  # Integrations
  # c.use :active_job,    service_name: 'worker'
  # c.use :active_record, service_name: 'database'
  # c.use :aws,           service_name: 'aws'
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
