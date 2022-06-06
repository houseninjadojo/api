class Sync::Property::Hubspot::Outbound::CreatePolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    has_external_id?
  end

  def has_external_id?
    record.user&.hubspot_id.present?
  end
end
