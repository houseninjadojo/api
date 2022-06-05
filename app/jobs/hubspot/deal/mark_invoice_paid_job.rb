class Hubspot::Deal::MarkInvoicePaidJob < ApplicationJob
  queue_as :default

  attr_accessor :invoice

  def perform(invoice)
    ActiveSupport::Deprecation.warn('use Sync::WorkOrder::Hubspot::OutboundJob instead')

    @invoice = invoice
    return unless conditions_met?

    mark_deal_paid!
  end

  def conditions_met?
    [
      invoice.present?,
      invoice.work_order.present?,
      invoice.work_order.hubspot_id.present?,
    ].all?
  end

  def mark_deal_paid!
    Hubspot::Deal.update!(
      invoice.work_order.hubspot_id,
      {
        "invoice_paid" => "Yes",
      }
    )
  end
end
