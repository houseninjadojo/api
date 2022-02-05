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
      puts e
      render status: 400
    end
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
