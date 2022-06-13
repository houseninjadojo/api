class Sync::User::Hubspot::Inbound::UpdatePolicy < ApplicationPolicy
  authorize :user, optional: true
  authorize :webhook_event

  def can_sync?
    enabled? &&
    webhook_is_unprocessed? &&
    has_external_id? &&
    has_attribute_name? &&
    has_attribute_value?
  end

  def has_external_id?
    record["objectId"].present?
  end

  def has_attribute_name?
    record["propertyName"]
  end

  def has_attribute_value?
    !record["propertyValue"].nil? # use ! .nil?, empty "" is still valid, nil is not
  end

  def webhook_is_unprocessed?
    !webhook_event.processed?
  end

  def enabled?
    ENV["HUBSPOT_WEBHOOK_DISABLED"] != "true"
  end
end
