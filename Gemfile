source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

gem 'active_hash'
gem 'activejob-uniqueness', github: 'veeqo/activejob-uniqueness', ref: '76a7fe9'
gem 'amazing_print'
gem 'auth0'
gem 'action_policy',           '~> 0.6.4'
gem 'aws-sdk-s3',                          require: false
gem 'bootsnap',                '>= 1.9.3', require: false                      # Reduces boot times through caching; required in config/boot.rb
gem 'branch_io'
gem 'credit_card_validations'
gem 'ddtrace',                             require: 'ddtrace/auto_instrument'  # Datadog Metrics Instrumentation
gem 'dotenv-rails',                        require: 'dotenv/rails-now'         # ENV file management
gem 'fcm'
gem 'graphiti',         github: 'houseninjadojo/graphiti', branch: 'activerecord-filter-array-eq'
gem 'graphiti-rails'
gem 'httplog',          github: 'houseninjadojo/httplog', ref: 'b134d7a'
gem 'image_processing',        '~> 1.12'                                        # Use Active Storage variant
gem 'intercom'
gem 'hubspot-api-ruby', github: 'houseninjadojo/hubspot-api-ruby', ref: '8ae9b36'
# gem 'hubspot-api-client'
gem 'jwt'
gem 'kaminari'
gem 'kredis'                                                                   # Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
gem 'money'
gem 'monetize'
gem 'okcomputer'                                                               # Health Check
gem 'pg',                      '~> 1.4'                                        # Use postgresql as the database for Active Record
gem 'phonelib'
gem 'puma',                    '~> 6.0'                                        # Use Puma as the app server
gem 'rack-cors'                                                                # Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rails',                   '~> 7.0.4'                                      # Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails_semantic_logger'
gem 'redis',                   '~> 4.8'                                        # Use Redis adapter to run Action Cable in production
gem 'responders'
gem 'safer_rails_console', github: 'houseninjadojo/safer_rails_console', branch: 'redis'
gem 'seedbank'
gem 'sendgrid-actionmailer', github: 'houseninjadojo/sendgrid-actionmailer', ref: 'e55f2b3'
gem 'sentry-ruby'
gem 'sentry-rails'
gem 'sentry-sidekiq'
gem 'sidekiq',                 '~> 7.0'
gem 'stripe',                  '~> 7.1.0'
gem 'strong_migrations',       '~> 1.4.2'
gem 'treblle', github: 'mileszim/treblle-ruby', ref: 'd1972a8495a5dbb607bfc0fc178895e48c6906e1'
gem 'valid_email'

gem 'net-ssh', '7.0.1'

group :development, :test do
  gem 'factory_bot_rails'
  gem 'faker'                                              # Generate fake data
  gem 'graphiti_spec_helpers'
  gem 'rspec-rails',           '~> 6.0.1'
  gem 'rspec-sidekiq'
  gem 'rubocop-rails',                     require: false
  gem 'pry'
end

group :development do
  gem 'annotate'
  gem 'foreman'
  # gem 'vandal_ui' # install for API UI utility
end

group :test do
  gem 'database_cleaner'
end

group :sandbox, :production do
  gem 'cloudflare-rails'
end

# gem 'bcrypt',           '~> 3.1.7'                                        # Use Active Model has_secure_password
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]        # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
