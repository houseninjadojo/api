class Sync::WorkOrder::Hubspot::Inbound::DeletePolicy < ApplicationPolicy
  authorize :user, optional: true
  authorize :webhook_event

  def can_sync?
    enabled? &&
    webhook_is_unprocessed? &&
    has_external_id? &&
    !already_deleted?
  end

  def has_external_id?
    record["objectId"].present?
  end

  def already_deleted?
    entry.resource&.deleted_at.present?
  end

  def webhook_is_unprocessed?
    !webhook_event.processed?
  end

  def enabled?
    ENV["HUBSPOT_WEBHOOK_DISABLED"] != "true"
  end

  private

  def entry
    Hubspot::Webhook::Entry.new(webhook_event, record)
  end
end
