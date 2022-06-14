class Sync::User::Hubspot::Inbound::UpdateJob < ApplicationJob
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
    Sync::User::Hubspot::Inbound::UpdatePolicy.new(
      webhook_entry,
      webhook_event: webhook_event
    )
  end

  def entry
    Hubspot::Webhook::Entry.new(webhook_entry, webhook_event)
  end
end
