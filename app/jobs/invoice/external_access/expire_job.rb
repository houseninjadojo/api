class Invoice::ExternalAccess::ExpireJob < ApplicationJob
  queue_as :default

  attr_accessor :invoice

  def perform(invoice)
    @invoice = invoice
    return unless conditions_met?

    invoice.expire_external_access!
    delete_hubspot_branch_payment_link!
  end

  def conditions_met?
    [
      invoice.present?,
      invoice.work_order.present?,
      invoice.work_order.hubspot_id.present?,
    ].all?
  end

  def delete_hubspot_branch_payment_link!
    Hubspot::Deal.update!(
      invoice.work_order.hubpot_id,
      { "branch_payment_link" => nil }
    )
  end
end
