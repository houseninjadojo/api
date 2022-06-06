class Sync::Subscription::Stripe::Outbound::CreatePolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    !has_external_id? &&
    has_customer_id? &&
    has_price_id? &&
    has_payment_method_id?
  end

  def has_external_id?
    record.stripe_id.present?
  end

  def has_customer_id?
    record&.user&.stripe_id.present?
  end

  def has_price_id?
    record&.subscription_plan&.stripe_price_id.present?
  end

  def has_payment_method_id?
    record&.payment_method&.stripe_id.present?
  end
end
