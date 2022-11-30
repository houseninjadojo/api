class Sync::Estimate::Hubspot::Outbound::UpdatePolicy < ApplicationPolicy
  class Changeset < TreeDiff
    observe :approved_at,
            :declined_at
  end

  authorize :user, optional: true
  authorize :changeset

  def can_sync?
    if !Rails.env.test?
      Rails.logger.info("sync policy action=update estimate=#{record.id}", {
        policy: {
          resource: "estimate",
          service: "hubspot",
          direction: "outbound",
          action: "update",
          result: can_sync_result,
        },
        resource: {
          id: record&.id,
          type: "estimate",
        },
        factors: {
          has_external_id: has_external_id?,
          has_changed_attributes: has_changed_attributes?,
          has_present_attributes: has_present_attributes?,
          enabled: enabled?,
        },
        changeset: changeset,
      })
    end
    can_sync_result
  end

  def can_sync_result
    has_external_id? &&
    has_changed_attributes? &&
    has_present_attributes? &&
    enabled?
  end

  def has_external_id?
    record.work_order&.hubspot_id.present?
  end

  def has_changed_attributes?
    !changeset.blank?
  end

  def has_present_attributes?
    record.approved_at.present? || record.declined_at.present?
  end

  def enabled?
    ENV["HUBSPOT_OUTBOUND_DISABLED"] != "true"
  end
end
