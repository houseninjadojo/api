class Sync::Estimate::Hubspot::Outbound::UpdatePolicy < ApplicationPolicy
  class Changeset < TreeDiff
    observe :approved_at,
            :declined_at
  end

  authorize :user, optional: true
  authorize :changeset

  def can_sync?
    Rails.logger.info("Estimate::Hubspot::Outbound::UpdatePolicy.can_sync?")
    Rails.logger.info("  has_external_id?=#{has_external_id?}")
    Rails.logger.info("  has_changed_attributes?=#{has_changed_attributes?}")
    Rails.logger.info("  is_modifiable?=#{has_present_attributes?}")
    Rails.logger.info("  enabled?=#{enabled?}")
    Rails.logger.info("changeset: #{changeset.inspect}")
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
