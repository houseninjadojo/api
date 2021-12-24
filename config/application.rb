require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Require settings
require_relative "../lib/core_ext/rails/settings"

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
  end
end
