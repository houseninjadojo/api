class WebhooksController < ApplicationController
  skip_before_action :authenticate_request!

  def stripe
    begin
      event = build_stripe_webhook_event.to_hash
      webhook_event = WebhookEvent.create!(service: 'stripe', payload: event)
      Stripe::HandleWebhookJob.perform_later(webhook_event)
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
      event = WebhookEvent.create!(service: 'hubspot', payload: content)
      content.each do |payload|
        Hubspot::HandleWebhookJob.perform_later(webhook_event, payload)
      end
    rescue
      WebhookEvent.create!(service: 'hubspot', payload: event)
    end
    render status: :ok
  end

  private

  def build_stripe_webhook_event
    payload = request.body.read
    Stripe::Webhook.construct_event(
      payload,
      stripe_signature_header,
      stripe_webhook_secret
    )
  end

  def stripe_signature_header
    request.headers['HTTP_STRIPE_SIGNATURE']
  end

  def stripe_webhook_secret
    Rails.application.credentials.stripe.dig(:webhook_secret)
  end
end
