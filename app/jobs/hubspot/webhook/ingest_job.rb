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
      payload.deal_batch_entry.handler.perform_later(@webhook_event, payload.deal_batch_entry)
    else
      payload.entries.each do |entry|
        entry.handler.perform_later(@webhook_event, entry.payload)
      end
    end
  end
end
