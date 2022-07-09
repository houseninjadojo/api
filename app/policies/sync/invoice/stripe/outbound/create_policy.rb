class Sync::Invoice::Stripe::Outbound::CreatePolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    !has_external_id? &&
    has_customer_id? &&
    (has_payment_method_id? || has_subscription_id?) &&
    !is_walkthrough?
  end

  def has_external_id?
    record.stripe_id.present?
  end

  def has_customer_id?
    record&.user&.stripe_id.present?
  end

  def has_payment_method_id?
    record&.user&.default_payment_method&.stripe_id.present?
  end

  def has_subscription_id?
    record&.subscription&.stripe_id.present?
  end

  def is_walkthrough?
    record&.work_order&.is_walkthrough?
  end
end
