class Sync::Webhook::StripeJob < ApplicationJob
  sidekiq_options retry: 0
  queue_as :default

  attr_accessor :webhook_event

  def perform(webhook_event)
    @webhook_event = webhook_event
    return unless policy.can_sync?

    handler&.perform_now(webhook_event)
  end

  def payload
    @payload ||= webhook_event.payload
  end

  def event_type
    @event_type ||= payload["type"]
  end

  def event_resource_type
    type = event_type.split(".")
    if type.length == 3
      type[1]
    else
      type[0]
    end
  end

  def event_action
    type = event_type.split(".")
    if type.length == 3
      type[2]
    else
      type[1]
    end
  end

  def resource_klass
    case event_resource_type
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

  def policy
    Sync::Webhook::StripePolicy.new(webhook_event)
  end
end
