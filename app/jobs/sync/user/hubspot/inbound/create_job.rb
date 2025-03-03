class Sync::User::Hubspot::Inbound::CreateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :webhook_entry, :webhook_event

  delegate :resource_klass, :attribute_name, :attribute_value, to: :entry

  def perform(webhook_event, webhook_entry)
    @webhook_entry = webhook_entry
    @webhook_event = webhook_event

    return unless policy.can_sync?

    resource_klass.create!(params)

    webhook_event.update!(processed_at: Time.now)
  end

  def policy
    Sync::User::Hubspot::Inbound::CreatePolicy.new(
      webhook_entry,
      webhook_event: webhook_event
    )
  end

  def payload
    Hubspot::Webhook::Payload.new(webhook_event)
  end

  def entry
    Hubspot::Webhook::Entry.new(webhook_event, webhook_entry)
  end

  def params
    payload.as_params
  end
end
