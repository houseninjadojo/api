class Sync::PromoCode::Stripe::Outbound::CreateJob < ApplicationJob
  queue_as :default

  attr_accessor :resource

  def perform(resource)
    @resource = resource
    return unless policy.can_sync?

    # Create Promo Code
    # @see https://stripe.com/docs/api/promotion_codes/create
    promo_code = Stripe::PromotionCode.create(params)
    resource.update!(
      stripe_id: promo_code.id,
      stripe_object: promo_code,
    )
  end

  def params
    {
      coupon: resource.coupon_id,
      code: resource.code,
    }
  end

  def policy
    Sync::PromoCode::Stripe::Outbound::CreatePolicy.new(
      resource
    )
  end
end
