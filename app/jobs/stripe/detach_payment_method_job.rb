class Stripe::DetachPaymentMethodJob < ApplicationJob
  queue_as :default

  def perform(stripe_token)
    return unless can_run_this_job?(stripe_token)

    Stripe::PaymentMethod.detach(stripe_token)
  end

  def can_run_this_job?(stripe_token)
    stripe_token.present?
  end
end
