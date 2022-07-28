class Sync::PromoCode::Stripe::Outbound::CreateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :resource

  def perform(resource)
    @resource = resource
    return unless policy.can_sync?

    # Create Promo Code
    # @see https://stripe.com/docs/api/promotion_codes/create
    promo_code = Stripe::PromotionCode.create(params, { idempotency_key: idempotency_key })
    resource.update!(
      stripe_id: promo_code.id,
      stripe_object: promo_code,
      active: promo_code.active,
      name: promo_code.coupon&.name,
      percent_off: promo_code.coupon&.percent_off,
      amount_off: promo_code.coupon&.amount_off,
      duration: promo_code.coupon&.duration,
      duration_in_months: promo_code.coupon&.duration_in_months,
    )
  end

  def params
    {
      coupon: resource.coupon_id,
      code: resource.code,
      metadata: {
        house_ninja_id: resource.id,
      }
    }
  end

  def policy
    Sync::PromoCode::Stripe::Outbound::CreatePolicy.new(
      resource
    )
  end

  def idempotency_key
    Digest::SHA256.hexdigest("#{resource.id}#{resource.updated_at.to_i}")
  end
end
