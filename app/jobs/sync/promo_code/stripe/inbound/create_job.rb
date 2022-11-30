class Sync::PromoCode::Stripe::Inbound::CreateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :webhook_event
  attr_accessor :promo_code

  def perform(webhook_event)
    @webhook_event = webhook_event

    return unless policy.can_sync?

    @promo_code = PromoCode.create!(params)

    webhook_event.update!(processed_at: Time.now, webhookable: promo_code)
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
    if stripe_object.object == 'coupon' && coupon.present?
      params_from_coupon
    else
      params_from_promo_code
    end
  end

  def params_from_promo_code
    {
      active: stripe_object.active,
      code: stripe_object.code,
      name: stripe_object.coupon.name,
      percent_off: stripe_object.coupon.percent_off,
      amount_off: stripe_object.coupon.amount_off,
      coupon_id: stripe_object.coupon.id,
      duration: stripe_object.coupon.duration,
      duration_in_months: stripe_object.coupon.duration_in_months,
      created_at: Time.at(stripe_object.created),

      stripe_id: stripe_object.id,
      stripe_object: stripe_object,
    }.compact
  end

  def params_from_coupon
    {
      active: true,
      code: stripe_object.id,
      name: coupon&.name,
      percent_off: coupon&.percent_off,
      amount_off: coupon&.amount_off,
      coupon_id: coupon&.id,
      duration: coupon&.duration,
      duration_in_months: coupon&.duration_in_months,
      created_at: Time.at(stripe_object.created),

      stripe_id: nil,
      stripe_object: stripe_object,
    }.compact
  end

  def coupon_object
    stripe_object.is_a?(Stripe::PromotionCode) ? stripe_object.coupon : stripe_object
  end

  def coupon
    @coupon ||= PromoCode.find_coupon_by(months: coupon_object.duration_in_months)
  end
end
