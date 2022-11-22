unless Rails.env.test?
  Hubspot.configure({
    access_token: Rails.application.credentials.hubspot.dig(:app_token),
    client_id: Rails.application.credentials.hubspot.dig(:client_id),
    client_secret: Rails.application.credentials.hubspot.dig(:client_secret),
    redirect_uri: "https://#{Rails.settings.domains.dig(:app)}/webhooks/hubspot",
  })
end
