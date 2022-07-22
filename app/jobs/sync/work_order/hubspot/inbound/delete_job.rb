class Sync::WorkOrder::Hubspot::Inbound::DeleteJob < Sync::BaseJob
  queue_as :default

  attr_accessor :webhook_entry, :webhook_event

  delegate :resource, to: :entry

  def perform(webhook_event, webhook_entry)
    @webhook_entry = webhook_entry
    @webhook_event = webhook_event

    return unless policy.can_sync?

    ActiveRecord::Base.transaction do
      resource.update!(deleted_at: Time.now)

      webhook_event.update!(
        processed_at: Time.now,
        webhookable: resource
      )
    end
  end

  def policy
    Sync::WorkOrder::Hubspot::Inbound::DeletePolicy.new(
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
