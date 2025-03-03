require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'graphiti/rails/railtie'

# core_ext
require_relative "../lib/core_ext/rails/settings"
require_relative "../lib/core_ext/ruby/array/intersect"
require_relative "../lib/core_ext/ruby/json/safe_parse"
require_relative "../lib/core_ext/rails/active_support/time"
require_relative "../app/lib/clean_backtrace_formatter"

module HouseNinja
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # @see https://api.rubyonrails.org/classes/Rails/Application/Configuration.html#method-i-load_defaults
    config.load_defaults 7.0

    # ActionController
    # Reflect the current app url options for use inside rails
    # @see https://edgeguides.rubyonrails.org/action_controller_overview.html#default-url-options
    config.action_controller.default_url_options = {
      host: Rails.settings.domains[:api],
      port: ENV.fetch("PORT") { 3000 }
    }

    # ActionMailer
    # Reflect the current app url options for use inside rails
    # @see https://guides.rubyonrails.org/action_mailer_basics.html#generating-urls-in-action-mailer-views
    config.action_mailer.default_url_options = {
      host: Rails.settings.domains[:api],
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
    config.active_record.encryption.support_unencrypted_data = true
    config.active_record.encryption.extend_queries = true

    # ActiveStorage
    # use proxy for ActiveStorage
    # config.active_storage.resolve_model_to_route = :rails_storage_proxy

    # Set Redis as the cache store
    # @see https://guides.rubyonrails.org/caching_with_rails.html#activesupport-cache-rediscachestore
    config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }

    # I18n Configuration
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    # semantic logger
    config.semantic_logger.backtrace_level = :error
    # config.rails_semantic_logger.quiet_assets = true
    config.colorize_logging = true

    # time zone
    # config.time_zone = 'Pacific Time (US & Canada)'

    # config.debug_exception_response_format = :api
    # config.action_dispatch.show_exceptions = false

    config.log_tags = {
      request_id: :request_id,
      ip: :remote_ip,
      # user_id: -> { current_user&.id },
      headers: -> request {
        headers = {}
        request.headers.each do |key, value|
          if key.is_a?(String) && key.start_with?("HTTP_")
            case key
            when "HTTP_X_HN_USER_PERMISSIONS"
            when "HTTP_X_JWT_CLAIMS"
              headers[key] = JSON.safe_parse(value)
            else
              headers[key] = value
            end
          end
        end
        headers.except(
          "HTTP_COOKIE",
          "HTTP_AUTHORIZATION",
          "X-HTTP_AUTHORIZATION",
          "X_HTTP_AUTHORIZATION",
          "HTTP_X_CSRF_TOKEN",
          "REDIRECT_X_HTTP_AUTHORIZATION"
        )
      }
    }

    # Rails Safer Console
    # https://github.com/salsify/safer_rails_console
    config.safer_rails_console.sandbox_environments = %w{sandbox production}
    config.safer_rails_console.console = 'irb'
    config.safer_rails_console.environment_names = {
      'development' => 'development',
      'sandbox' => 'sandbox',
      'production' => 'production',
    }
    config.safer_rails_console.environment_prompt_colors = {
      'development' => SaferRailsConsole::Colors::GREEN,
      'sandbox' => SaferRailsConsole::Colors::YELLOW,
      'production' => SaferRailsConsole::Colors::RED
    }
    config.safer_rails_console.warn_environments = %w{sandbox production}
    config.safer_rails_console.warn_text = <<~TEXT
      WARNING: YOU ARE USING RAILS CONSOLE IN PRODUCTION!
      Changing data can cause serious data loss.
      Make sure you know what you're doing.
    TEXT
  end
end

module Rails
  def self.secrets
    Rails.application.credentials
  end
end
