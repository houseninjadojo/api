class Stripe::CreateChargeJob < ApplicationJob
  queue_as :default

  def perform(payment)
    return if payment.was_charged?

    charge = Stripe::Charge.create(params)
    payment.update(stripe_id: charge.id, stripe_object: charge.as_json)
  end

  private

  def params
    {
      amount: payment.amount,
      currency: 'usd',
      customer: payment.user.stripe_id,
      description: payment.description,
      metadata: {
        houseninja_payment_id: payment.id,
      },
      source: payment.payment_method.stripe_id,
      statement_descriptor: payment.statement_descriptor,
    }
  end
end
