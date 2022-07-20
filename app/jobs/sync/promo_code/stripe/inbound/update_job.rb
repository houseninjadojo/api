class Sync::PromoCode::Stripe::Inbound::UpdateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :webhook_event

  def perform(webhook_event)
    @webhook_event = webhook_event

    return unless policy.can_sync?

    promo_code.update!(params)

    webhook_event.update!(processed_at: Time.now, webhookable: promo_code)
  end

  def policy
    Sync::PromoCode::Stripe::Inbound::UpdatePolicy.new(
      stripe_event,
      webhook_event: webhook_event
    )
  end

  def stripe_event
    @resource ||= Stripe::Event.construct_from(webhook_event.payload)
  end

  def stripe_object
    stripe_event.data.object
  end

  def promo_code
    @promo_code ||= PromoCode.find_by(stripe_id: stripe_object.id) if stripe_object&.id.present?
  end

  def params
    {
      active: stripe_object.active,
      code: stripe_object.code,
      name: stripe_object.coupon.name,
      percent_off: stripe_object.coupon.percent_off,
      amount_off: stripe_object.coupon.amount_off,
      duration: stripe_object.coupon.duration,
      duration_in_months: stripe_object.coupon.duration_in_months,
      coupon_id: stripe_object.coupon.id,

      stripe_object: stripe_object.to_json,
    }.compact
  end
end
