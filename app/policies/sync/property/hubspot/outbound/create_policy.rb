class Sync::Property::Hubspot::Outbound::CreatePolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    has_external_id? &&
    enabled?
  end

  def has_external_id?
    record.user&.hubspot_id.present?
  end

  def enabled?
    ENV["HUBSPOT_OUTBOUND_DISABLED"] != "true"
  end
end
