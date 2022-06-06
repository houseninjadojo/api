class Sync::PaymentMethod::Stripe::Outbound::DeletePolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    has_external_id?
  end

  def has_external_id?
    record.stripe_id.present?
  end
end
