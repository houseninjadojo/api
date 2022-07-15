class Sync::WorkOrder::Hubspot::Outbound::UpdatePolicy < ApplicationPolicy
  class Changeset < TreeDiff
    observe :status,
            deep_link: [
              :url,
            ]
  end

  authorize :user, optional: true
  authorize :changeset

  def can_sync?
    has_external_id? &&
    has_pipeline_external_id? &&
    has_changed_attributes? &&
    enabled?
  end

  def has_external_id?
    record.hubspot_id.present?
  end

  def has_pipeline_external_id?
    record.status&.hubspot_id.present?
  end

  def has_changed_attributes?
    !changeset.blank?
  end

  def enabled?
    ENV["HUBSPOT_OUTBOUND_DISABLED"] != "true"
  end
end
