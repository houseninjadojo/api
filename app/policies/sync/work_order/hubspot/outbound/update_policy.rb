class Sync::WorkOrder::Hubspot::Outbound::UpdatePolicy < ApplicationPolicy
  class Changeset < TreeDiff
    observe :status,
            :deep_link
  end

  authorize :user, optional: true
  authorize :changeset

  def can_sync?
    has_external_id? &&
    has_changed_attributes?
  end

  def has_external_id?
    record.hubspot_id.present?
  end

  def has_changed_attributes?
    !changeset.blank?
  end
end
