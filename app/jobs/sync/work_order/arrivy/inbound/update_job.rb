class Sync::WorkOrder::Arrivy::Inbound::UpdateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :webhook_event

  def perform(webhook_event)
    @webhook_event = webhook_event

    return unless policy.can_sync?

    work_order.update!(params)

    webhook_event.update!(processed_at: Time.now)
  end

  def policy
    Sync::WorkOrder::Arrivy::Inbound::UpdatePolicy.new(
      arrivy_event,
      webhook_event: webhook_event
    )
  end

  def params
    {
      arrivy_id: arrivy_event.arrivy_id,
      scheduled_date: arrivy_event.scheduled_date,
      scheduled_time: arrivy_event.scheduled_time,
      scheduled_window_start: arrivy_event.scheduled_window_start,
      scheduled_window_end: arrivy_event.scheduled_window_end,
    }
  end

  def arrivy_event
    Arrivy::Event.new(webhook_event.payload)
  end

  def work_order
    @work_order ||= WorkOrder.find_by(hubspot_id: arrivy_event.hubspot_id)
  end
end
