source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.3"

gem 'auth0'
gem 'bootsnap',           '>= 1.9.3', require: false                      # Reduces boot times through caching; required in config/boot.rb
gem 'ddtrace',                        require: 'ddtrace/auto_instrument'  # Datadog Metrics Instrumentation
gem 'dotenv-rails',                   require: 'dotenv/rails-now'         # ENV file management
gem 'graphiti', github: 'houseninjadojo/graphiti', branch: 'activerecord-filter-array-eq'
gem 'graphiti-rails'
gem 'image_processing',   '~> 1.12'                                        # Use Active Storage variant
gem 'hubspot-api-ruby', github: 'captaincontrat/hubspot-api-ruby'
gem 'jwt'
gem 'kaminari'
gem 'kredis'                                                              # Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
gem 'lograge',            '~> 0.11.2'
gem 'okcomputer'                                                          # Health Check
gem 'pg',                 '~> 1.3'                                        # Use postgresql as the database for Active Record
gem 'phonelib'
gem 'puma',               '~> 5.6'                                        # Use Puma as the app server
gem 'rack-cors'                                                           # Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rails',              '~> 7.0.1'                                      # Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'redis',              '~> 4.5'                                        # Use Redis adapter to run Action Cable in production
gem 'responders'
gem 'seedbank'
gem 'sidekiq',            '~> 6.4'
gem 'stripe',             '~> 5.43.0'
gem 'valid_email'

group :development, :test do
  gem 'factory_bot_rails'
  gem 'faker'                                              # Generate fake data
  gem 'graphiti_spec_helpers'
  gem 'rspec-rails',           '~> 5.1.0'
  gem 'rubocop-rails',                     require: false
  gem 'pry'
end

group :development do
  gem 'annotate', github: 'dabit/annotate_models', branch: 'rails-7'
  gem 'foreman'
end

group :test do
  gem 'database_cleaner'
end

# gem 'bcrypt',           '~> 3.1.7'                                        # Use Active Model has_secure_password
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]        # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
