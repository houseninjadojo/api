require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'graphiti/rails/railtie'

# core_ext
require_relative "../lib/core_ext/rails/settings"
require_relative "../lib/core_ext/ruby/array/intersect"

module HouseNinja
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # @see https://api.rubyonrails.org/classes/Rails/Application/Configuration.html#method-i-load_defaults
    config.load_defaults 7.0

    # ActionController
    # Reflect the current app url options for use inside rails
    # @see https://edgeguides.rubyonrails.org/action_controller_overview.html#default-url-options
    config.action_controller.default_url_options = {
      host: Rails.settings.domains[:app],
      port: ENV.fetch("PORT") { 3000 }
    }

    # ActionMailer
    # Reflect the current app url options for use inside rails
    # @see https://guides.rubyonrails.org/action_mailer_basics.html#generating-urls-in-action-mailer-views
    config.action_mailer.default_url_options = {
      host: Rails.settings.domains[:app],
      port: ENV.fetch("PORT") { 3000 }
    }

    # ActiveJob
    # Use Sidekiq as ActiveJob worker
    # @see https://edgeguides.rubyonrails.org/active_job_basics.html#backends
    config.active_job.queue_adapter = :sidekiq

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    # @see https://api.rubyonrails.org/classes/Rails/Application/Configuration.html#method-i-api_only-3D
    config.api_only = true

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Store a reference to the encryption key in the encrypted message for
    # more performant decryption
    # @see https://edgeguides.rubyonrails.org/active_record_encryption.html#storing-key-references
    config.active_record.encryption.store_key_references = true

    # Set Redis as the cache store
    # @see https://guides.rubyonrails.org/caching_with_rails.html#activesupport-cache-rediscachestore
    config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }

    # I18n Configuration
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    # lograge
    config.lograge.enabled = false
    config.lograge.base_controller_class = 'ActionController::API'
    config.lograge.formatter = Lograge::Formatters::Json.new
    config.lograge.custom_options = lambda do |event|
      # Retrieves trace information for current thread
      correlation = Datadog.tracer.active_correlation
      {
        # Adds IDs as tags to log output
        :dd => {
          # To preserve precision during JSON serialization, use strings for large numbers
          :trace_id => correlation.trace_id.to_s,
          :span_id => correlation.span_id.to_s,
          :env => correlation.env.to_s,
          :service => correlation.service.to_s,
          :version => correlation.version.to_s
        },
        :ddsource => ["ruby"],
        :params => event.payload[:params].reject { |k| %w(controller action).include? k }
      }
    end

    # config.debug_exception_response_format = :api
    # config.action_dispatch.show_exceptions = false
  end
end

module Rails
  def self.secrets
    Rails.application.credentials
  end
end
