class Stripe::CreatePaymentMethodJob < ApplicationJob
  queue_as :critical

  def perform(payment_method)
    return if payment_method.stripe_token.present?

    params = params(payment_method)
    payment_method = Stripe::PaymentMethod.create(params)
    payment_method.update!(stripe_token: payment_method.id)

    if payment_method.user && payment_method.user.stripe_customer_id.present?
      Stripe::AttachPaymentMethodJob.perform_later(payment_method, payment_method.user)
    end
  end

  def params(payment_method)
    # @todo
    # assuming this is a card for now, but it should be more generic
    {
      type: 'card',
      card: {
        number: payment_method.card_number,
        exp_month: payment_method.exp_month,
        exp_year: payment_method.exp_year,
        cvv: payment_method,
      }
    }
  end
end
