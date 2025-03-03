class Stripe::Invoices::FinalizeJob < ApplicationJob
  queue_as :default

  def perform(invoice)
    ActiveSupport::Deprecation.warn("Stripe::Invoices::FinalizeJob is deprecated.")

    @invoice = invoice
    return unless conditions_met?

    # finalized_invoice = Stripe::Invoice.finalize_invoice(invoice.stripe_id, params)
    # payment_intent = Stripe::PaymentIntent.retrieve(finalized_invoice.payment_intent)
    # payment = Payment.create_from_payment_intent(payment_intent)
    # we should be handling this via webhooks
    # invoice.update!(finalized_at: Time.now)
  end

  def params
    {
      auto_advance: false,
    }
  end

  private

  def conditions_met?
    [
      @invoice.finalized_at.nil?,
      @invoice.stripe_id.present?,
    ].all?
  end
end
