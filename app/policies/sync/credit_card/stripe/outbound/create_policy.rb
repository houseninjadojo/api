class Sync::CreditCard::Stripe::Outbound::CreatePolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    !has_external_id? &&
    user_has_external_id? &&
    !persisted?
  end

  def has_external_id?
    record.stripe_id.present?
  end

  def user_has_external_id?
    record&.user&.stripe_id.present?
  end

  def persisted?
    record.try(:persisted?)
  end
end
