class Sync::PromoCode::Stripe::Outbound::CreatePolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    !has_external_id? && has_coupon_id?
  end

  def has_external_id?
    record.stripe_id.present?
  end

  def has_coupon_id?
    record.coupon_id.present?
  end
end
