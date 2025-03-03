class Stripe::Invoices::PayJob < ApplicationJob
  queue_as :default

  def perform(invoice)
    ActiveSupport::Deprecation.warn("Stripe::Invoices::PayJob is deprecated.")
    @invoice = invoice
    return unless conditions_met?

    # Stripe::Invoice.pay(@invoice.stripe_id, params)
  end

  private

  def params
    {
      payment_method: @invoice.user.default_payment_method.stripe_token,
    }
  end

  def conditions_met?
    [
      @invoice.try(:stripe_id).present?,
      @invoice.try(:user).try(:default_payment_method).try(:stripe_token).present?
    ].all?
  end
end
