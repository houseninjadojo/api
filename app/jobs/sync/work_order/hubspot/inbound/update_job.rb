class Sync::WorkOrder::Hubspot::Inbound::UpdateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :webhook_entry, :webhook_event

  delegate :resource, :attribute_name, :attribute_value, to: :entry

  def perform(webhook_event, webhook_entry)
    @webhook_entry = webhook_entry
    @webhook_event = webhook_event

    return unless policy.can_sync?

    resource.update!(attribute_name => attribute_value)

    webhook_event.update!(processed_at: Time.now)
  end

  def policy
    Sync::WorkOrder::Hubspot::Inbound::UpdatePolicy.new(
      webhook_entry,
      webhook_event: webhook_event
    )
  end

  def entry
    Hubspot::Webhook::Entry.new(webhook_event, webhook_entry)
  end

  # def sync_line_items!
  #   Hubspot::Deal::SyncLineItemsJob.perform_later(webhook_entry.hubspot_id, )
  # end
end
