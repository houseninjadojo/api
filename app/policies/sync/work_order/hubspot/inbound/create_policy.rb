class Sync::WorkOrder::Hubspot::Inbound::CreatePolicy < ApplicationPolicy
  authorize :user, optional: true
  authorize :webhook_event

  def can_sync?
    enabled? &&
    webhook_is_unprocessed? &&
    has_external_id? &&
    is_create_event? &&
    is_new_record?
  end

  def has_external_id?
    record.first["objectId"].present?
  end

  def is_create_event?
    payload.is_deal_batch?
  end

  def is_new_record?
    !WorkOrder.exists?(hubspot_id: record.first["objectId"]&.to_s)
  end

  def webhook_is_unprocessed?
    !webhook_event.processed?
  end

  def enabled?
    ENV["HUBSPOT_WEBHOOK_DISABLED"] != "true"
  end

  private

  def payload
    Hubspot::Webhook::Payload.new(webhook_event)
  end
end
