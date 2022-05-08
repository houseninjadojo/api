class Stripe::Invoices::FinalizeJob < ApplicationJob
  queue_as :default

  def perform(invoice)
    @invoice = invoice
    return unless conditions_met?

    Stripe::Invoice.finalize_invoice(invoice.stripe_id)
    # we should be handling this via webhooks
    # invoice.update!(finalized_at: Time.now)
  end

  private

  def conditions_met?
    [
      @invoice.finalized_at.nil?,
      @invoice.stripe_id.present?,
    ].all?
  end
end
