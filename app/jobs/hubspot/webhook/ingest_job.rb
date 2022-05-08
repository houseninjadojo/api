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
    @webhook_event.payload
  end

  def ingest!
    if is_deal_batch?
      ingest_deal_batch!
    else
      ingest_each_entry!
    end
  end

  # when a deal is created, hubspot sends several `propertyChange` events,
  # one `creation` event, and 0 other events. We can use this particularity
  # as a kind of "webhook payload signature".
  def is_deal_batch?
    @payload.pluck("subscriptionType").uniq == ["deal.propertyChange", "deal.creation"]
  end

  def ingest_deal_batch!
    entry = @payload.find { |i| i["subscriptionType"] == "deal.creation" }
    process_payload_item(entry)
  end

  def ingest_each_entry!
    @payload.each do |entry|
      job = handler_job(entry)
      job.perform_later(entry, @webhook_event)
    end
  end

  def handler_job(entry)
    case entry["subscriptionType"]
    when "contact.propertyChange"
      # Hubspot::Webhook::Handler::Contact::PropertyChangeJob.perform_later(entry, @webhook_event)
      return Hubspot::Webhook::Handler::Contact::PropertyChangeJob
    when "contact.creation"
      # Hubspot::Webhook::Handler::Contact::CreationJob.perform_later(entry, @webhook_event)
      return Hubspot::Webhook::Handler::Contact::CreationJob
    when "contact.privacyDeletion"
      # Hubspot::Webhook::Handler::Contact::PrivacyDeletionJob
      return
    when "contact.deletion"
      # Hubspot::Webhook::Handler::Contact::DeletionJob
      return
    when "deal.propertyChange"
      # Hubspot::Webhook::Handler::Deal::PropertyChangeJob.perform_later(entry, @webhook_event)
      Hubspot::Webhook::Handler::Deal::PropertyChangeJob
      return
    when "deal.creation"
      # Hubspot::Webhook::Handler::Deal::CreationJob.perform_later(hubspot_id, @webhook_event)
      Hubspot::Webhook::Handler::Deal::CreationJob
      return
    when "deal.deletion"
      # Hubspot::Webhook::Handler::Deal::DeletionJob
      return
    end
  end
end
