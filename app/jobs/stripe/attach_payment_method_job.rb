class Stripe::AttachPaymentMethodJob < ApplicationJob
  queue_as :critical

  def perform(payment_method, user)
    return unless can_run_this_job?(payment_method, user)

    params = { customer: user.stripe_customer_id }
    Stripe::PaymentMethod.attach(payment_method.stripe_token, params)
  end

  def can_run_this_job?(payment_method, user)
    payment_method.stripe_token.present? && user.stripe_customer_id.present?
  end
end
