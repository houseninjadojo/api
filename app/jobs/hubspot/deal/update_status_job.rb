class Hubspot::Deal::UpdateStatusJob < ApplicationJob
  queue_as :default

  attr_accessor :work_order

  def perform(work_order)
    ActiveSupport::Deprecation.warn('use Sync::WorkOrder::Hubspot::Outbound::UpdateJob instead')
    @work_order = work_order
    return unless conditions_met?

    update_status!
  end

  def conditions_met?
    [
      work_order.present?,
      work_order.hubspot_id.present?,
      work_order.status.present?,
    ].all?
  end

  def update_status!
    Hubspot::Deal.update!(
      work_order.hubspot_id,
      {
        dealstage: work_order.status.hubspot_id,
      }
    )
  end
end
