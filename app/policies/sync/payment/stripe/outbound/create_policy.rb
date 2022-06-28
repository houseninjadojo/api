class Sync::Payment::Stripe::Outbound::CreatePolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    !has_external_id? &&
    user_has_external_id? &&
    (invoice_has_external_id? || payment_method_has_external_id?) &&
    !invoice_already_paid?
  end

  def has_external_id?
    record&.stripe_id.present?
  end

  def user_has_external_id?
    record&.invoice&.user&.stripe_id.present?
  end

  def payment_method_has_external_id?
    record&.payment_method&.stripe_id.present?
  end

  def invoice_has_external_id?
    record&.invoice&.stripe_id.present?
  end

  def invoice_already_paid?
    record&.invoice&.paid?
  end
end
