unless Rails.env.test?
  Hubspot.configure({
    hapikey: Rails.application.credentials.hubspot.dig(:api_key),
    client_id: Rails.application.credentials.hubspot.dig(:client_id),
    client_secret: Rails.application.credentials.hubspot.dig(:client_secret),
    redirect_uri: "https://#{Rails.settings.domains.dig(:app)}/webhooks/hubspot",
  })
end
