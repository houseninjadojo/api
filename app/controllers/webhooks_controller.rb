class WebhooksController < ApplicationController
  skip_before_action :authenticate_request!

  def stripe
    begin
      event = stripe_webhook_event.to_hash
      webhook_event = WebhookEvent.create!(service: 'stripe', payload: event)
      Sync::Webhook::StripeJob.perform_later(webhook_event)
    rescue JSON::ParserError => e
      Rails.logger.error(e)
      render status: 400
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error(e)
      render status: 400
    end
  end

  def hubspot
    if params[:code]
      response = Hubspot::Oauth.create(params[:code])
      Rails.logger.info(response)
      redirect_to "https://app.hubspot.com/integrations-settings"
    end

    event = request.body.read
    begin
      content = JSON.parse(event)
      webhook_event = WebhookEvent.create!(service: 'hubspot', payload: content)
      content.each do |payload|
        Sync::Webhook::HubspotJob.perform_later(webhook_event)
      end
    rescue
      webhook_event = WebhookEvent.create!(service: 'hubspot', payload: event)
      Rails.logger.warn("Could not parse service=hubspot event=#{webhook_event.id}")
    end
    render status: :ok
  end

  def arrivy
    # if arrivy_webhook_header == arrivy_webhook_secret
    if true
      Rails.logger.info(request.headers)
      event = request.body.read
      begin
        content = JSON.parse(event)
        webhook_event = WebhookEvent.create!(service: 'arrivy', payload: content)
        Sync::Webhook::Arrivy.perform_later(webhook_event)
      rescue JSON::ParserError => e
        webhook_event = WebhookEvent.create!(service: 'arrivy', payload: event)
        Rails.logger.warn("JSON parse error: Could not parse service=arrivy event=#{webhook_event.id}")
      rescue
        webhook_event = WebhookEvent.create!(service: 'arrivy', payload: event)
        Rails.logger.warn("Could not parse service=arrivy event=#{webhook_event.id}")
      end
      render status: :ok
    else
      render status: :unauthorized
    end
  end

  private

  def stripe_webhook_event
    payload = request.body.read
    Stripe::Webhook.construct_event(
      payload,
      request.headers['HTTP_STRIPE_SIGNATURE'],
      Rails.application.credentials.stripe.dig(:webhook_secret)
    )
  end

  def arrivy_webhook_secret
    Rails.application.credentials.arrivy.dig(:webhook_secret)
  end

  def arrivy_webhook_header
    request.headers['ARRIVY_SECRET']
  end
end
