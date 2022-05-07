class Stripe::Invoices::CreateJob < ApplicationJob
  queue_as :default

  def perform(invoice)
    @invoice = invoice
    return unless conditions_met?

    stripe_invoice = Stripe::Invoice.create(params)
    @invoice.update!(
      stripe_id: stripe_invoice.id,
      stripe_object: stripe_invoice.as_json
    )
  end

  private

  def params
    {
      auto_advance: false,
      collection_method: "charge_automatically",
      customer: @invoice.user.stripe_id,
      default_payment_method: @invoice.user.default_payment_method.stripe_id,
      description: @invoice.description,
      subscription: @invoice.try(:subscription).try(:stripe_id),
    }
  end

  def conditions_met?
    [
      @invoice.stripe_id.nil?,
      @invoice.try(:user).try(:stripe_id).present?,
      @invoice.try(:user).try(:default_payment_method).try(:stripe_token).present?,
      # @invoice.try(:subscription).try(:stripe_id).present?
    ].all?
  end
end
