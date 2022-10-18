# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    if Rails.env.development?
      origins "localhost:4200", "co.houseninja.application"
    else
      origins /co\.houseninja\.application\:\/\//, /[a-z0-9]+\.houseninja\.pages\.dev/, "app.houseninja.co", "api-origin.houseninja.co", "tntmcgm6sar.live.verygoodproxy.com"
    end

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
