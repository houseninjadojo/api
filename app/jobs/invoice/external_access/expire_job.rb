class Invoice::ExternalAccess::ExpireJob < ApplicationJob
  queue_as :default

  attr_accessor :invoice

  def perform(invoice)
    @invoice = invoice
    return unless conditions_met?

    invoice.expire_external_access!
    expire_hubspot_access!
  end

  def conditions_met?
    [
      invoice.present?,
      invoice.work_order.present?,
      invoice.work_order.hubspot_id.present?,
    ].all?
  end

  def expire_hubspot_access!
    Hubspot::Deal.update!(
      invoice.work_order.hubpot_id,
      {
        "branch_payment_link" => nil,
      }
    )
  end
end
