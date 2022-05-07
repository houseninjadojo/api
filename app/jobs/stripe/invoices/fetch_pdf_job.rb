class Stripe::Invoices::FetchPdfJob < ApplicationJob
  queue_as :default

  def perform(invoice)
    @invoice = invoice
    return unless conditions_met?

    document = Document.create!(
      invoice: self,
      user: user
    )
    document.asset.attach(io: asset, filename: "invoice.pdf")
  end

  private

  def asset
    @asset ||= URI.open(@invoice.stripe_object["invoice_pdf"])
  end

  def conditions_met?
    [
      @invoice.document.nil?,
      @invoice.stripe_object["invoice_pdf"].try(:present?),
    ].all?
  end
end
