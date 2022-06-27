class Sync::Webhook::HubspotJob < ApplicationJob
  sidekiq_options retry: 0
  queue_as :default

  attr_accessor :webhook_event

  def perform(webhook_event)
    @webhook_event = webhook_event
    return unless policy.can_sync?

    ingest!
  end

  def payload
    @payload ||= Hubspot::Webhook::Payload.new(@webhook_event)
  end

  def ingest!
    if payload.is_create_batch?
      payload.create_batch_entry.handler.perform_later(webhook_event, payload.create_batch_entry.payload)
    else
      payload.entries.each do |entry|
        entry.handler.perform_later(webhook_event, entry.payload)
      end
    end
  end

  def policy
    Sync::Webhook::HubspotPolicy.new(webhook_event)
  end
end
