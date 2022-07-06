class Sync::Invoice::Stripe::Inbound::CreateJob < Sync::BaseJob
  attr_accessor :webhook_event

  def perform(webhook_event)
    @webhook_event = webhook_event

    return unless policy.can_sync?

    Invoice.create!(params)

    webhook_event.update!(processed_at: Time.now)
  end

  def policy
    Sync::Invoice::Stripe::Inbound::CreatePolicy.new(
      stripe_event,
      webhook_event: webhook_event
    )
  end

  def params
    {
      description: stripe_object.description,
      period_end: Time.at(stripe_object.period_end),
      period_start: Time.at(stripe_object.period_start),
      status: stripe_object.status,
      total: stripe_object.total,
      created_at: Time.at(stripe_object.created),

      payment: payment,
      promo_code: promo_code,
      subscription: subscription,
      user: user,

      stripe_id: stripe_object.id,
      stripe_object: stripe_object.to_json,
    }.compact
  end

  def user
    @user ||= User.find_by(stripe_id: stripe_object.customer)
  end

  def subscription
    @subscription ||= Subscription.find_by(stripe_id: stripe_object.subscription)
  end

  def payment
    @payment ||= Payment.find_by(stripe_id: stripe_object.charge)
  end

  def promo_code
    coupon_id = invoice_object&.discount&.coupon&.id
    @promo_code ||= PromoCode.find_by(coupon_id: coupon_id)
  end

  def stripe_event
    @resource ||= Stripe::Event.construct_from(webhook_event.payload)
  end

  def stripe_object
    stripe_event.data.object
  end

  # We need to expand discounts so we have to retrieve the invoice
  def invoice_object
    @invoice_object ||= Stripe::Invoice.retrieve(stripe_object.id, expand: "discounts")
  end
end
