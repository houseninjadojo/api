class Sync::WorkOrder::Hubspot::Outbound::UpdateJob < ApplicationJob
  queue_as :default

  attr_accessor :work_order, :changed_attributes

  def perform(work_order, changed_attributes)
    @changed_attributes = changed_attributes
    @work_order = work_order
    return unless policy.can_sync?

    Hubspot::Deal.update!(work_order.hubspot_id, params)
  end

  def params
    {
      dealstage: work_order.status.slug,
      invoice_paid: invoice_paid,
    }
  end

  def policy
    Sync::WorkOrder::Hubspot::Outbound::UpdatePolicy.new(
      work_order,
      changed_attributes: changed_attributes
    )
  end

  def invoice_paid
    if work_order&.invoice&.paid?
      "Yes"
    else
      "No"
    end
  end
end
