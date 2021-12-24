Datadog.configure do |c|
  # Service name
  c.service = 'api'

  # Enable in production only
  c.tracer.enabled = Rails.env.production?
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
  c.use :rails,   service_name: 'api'
  c.use :sidekiq, service_name: 'worker'
end
