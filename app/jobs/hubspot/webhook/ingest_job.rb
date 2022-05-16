class Hubspot::Webhook::IngestJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound
  sidekiq_options retry: 0
  queue_as :default

  def perform(webhook_event)
    @webhook_event = webhook_event
    return unless conditions_met?

    ingest!
  end

  private

  def conditions_met?
    [
      @webhook_event.processed_at.blank?,
    ].all?
  end

  def payload
    @payload ||= Hubspot::Webhook::Payload.new(@webhook_event)
  end

  def ingest!
    if payload.is_deal_batch?
      payload.deal_batch_entry.handler.perform_later(payload.deal_batch_entry, @webhook_event)
    else
      payload.entries.each do |entry|
        payload.handler.perform_later(entry.payload, @webhook_event)
      end
    end
  end
end
