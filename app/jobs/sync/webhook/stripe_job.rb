class Sync::Webhook::StripeJob < ApplicationJob
  sidekiq_options retry: 0
  queue_as :default

  attr_reader :webhook_event

  def perform(webhook_event)
    return if webhook_event.processed_at.present?
    return unless enabled?
    return unless handler.present?

    @webhook_event = webhook_event

    handler.perform_now(webhook_event)
  end

  def payload
    @payload ||= webhook_event.payload
  end

  def event_type
    @event_type ||= payload["type"]
  end

  def event_resource_type
    type = event_type.split(".")&.first
    if type.length == 3
      type[1]
    else
      type
    end
  end

  def event_action
    type = event_type.split(".")&.second
    if type.length == 3
      type[2]
    else
      type[1]
    end
  end

  def resource_klass
    case event_type
    when "charge"
      Payment
    when "customer"
      User
    when "subscription"
      Subscription
    when "invoice"
      Invoice
    when "invoiceitem"
      LineItem
    when "payment_method"
      PaymentMethod
    when "promotion_code"
      PromoCode
    end
  end

  def handler_action
    case event_action
    when "created"
      :create
    when "deleted"
      :delete
    else
      :update
    end
  end

  def handler
    [
      "Sync",
      "#{resource_klass}",
      "Stripe",
      "Inbound",
      "#{handler_action.capitalize}Job"
    ].join("::").safe_constantize
  end

  def enabled?
    ENV["STRIPE_WEBHOOK_DISABLED"] != "true"
  end
end
