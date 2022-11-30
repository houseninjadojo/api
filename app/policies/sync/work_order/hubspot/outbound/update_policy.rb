class Sync::WorkOrder::Hubspot::Outbound::UpdatePolicy < ApplicationPolicy
  class Changeset < TreeDiff
    observe :status,
            invoice_deep_link: [
              :url,
            ]
  end

  authorize :user, optional: true
  authorize :changeset

  def can_sync?
    if !Rails.env.test?
      Rails.logger.info("sync policy action=update work_order=#{record.id}", {
        policy: {
          resource: "work_order",
          service: "hubspot",
          direction: "outbound",
          action: "update",
          result: can_sync_result,
        },
        resource: {
          id: record&.id,
          type: "work_order",
        },
        factors: {
          has_external_id: has_external_id?,
          has_changed_attributes: has_changed_attributes?,
          has_pipeline_external_id: has_pipeline_external_id?,
          enabled: enabled?,
        },
        changeset: changeset,
      })
    end
    can_sync_result
  end

  def can_sync_result
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
