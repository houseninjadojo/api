class Sync::PromoCode::Stripe::Inbound::CreateJob < ApplicationJob
  queue_as :default

  attr_accessor :webhook_event

  def perform(webhook_event)
    @webhook_event = webhook_event

    return unless policy.can_sync?

    PromoCode.create!(params)

    webhook_event.update!(processed_at: Time.now)
  end

  def policy
    Sync::PromoCode::Stripe::Inbound::CreatePolicy.new(
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

  def params
    {
      active: stripe_object.active,
      code: stripe_object.code,
      name: stripe_object.coupon.name,
      percent_off: stripe_object.coupon.percent_off,
      amount_off: stripe_object.coupon.amount_off,
      coupon_id: stripe_object.coupon.id,
      created_at: Time.at(stripe_object.created),

      stripe_id: stripe_object.id,
      stripe_object: stripe_object.to_json,
    }
  end
end
