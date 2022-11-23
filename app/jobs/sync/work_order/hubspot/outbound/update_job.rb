class Sync::WorkOrder::Hubspot::Outbound::UpdateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :work_order, :changeset

  def perform(work_order, changeset)
    @changeset = changeset
    @work_order = work_order
    return unless policy.can_sync?

    Hubspot::Deal.update!(work_order.hubspot_id, params)
  end

  def params
    {
      dealstage: work_order.status.hubspot_id,
      invoice_paid: invoice_paid,
      branch_payment_link: branch_link,
      date_customer_paid_invoice: date_customer_paid_invoice,
      stripe_invoice_number: stripe_invoice_number,
      date_deal_added: date_deal_added,
    }
  end

  def policy
    Sync::WorkOrder::Hubspot::Outbound::UpdatePolicy.new(
      work_order,
      changeset: changeset
    )
  end

  def invoice_paid
    if work_order&.invoice&.paid?
      "Yes"
    else
      "No"
    end
  end

  def branch_link
    work_order.branch_payment_link&.url
  end

  def date_customer_paid_invoice
    epoch = work_order.invoice&.paid_at&.to_datetime.to_i * 1000
    epoch == 0 ? nil : epoch
  end

  def stripe_invoice_number
    work_order.invoice&.stripe_invoice_number
  end

  def date_deal_added
    # in central standard time
    offset = -6
    work_order.created_at&.in_time_zone(offset)&.iso8601
  end
end
