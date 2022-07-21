class Sync::User::Hubspot::Outbound::UpdatePolicy < ApplicationPolicy
  class Changeset < TreeDiff
    # observe :email,
    observe :contact_type,
            :first_name,
            :last_name,
            :phone_number,
            :onboarding_code,
            :onboarding_link,
            :onboarding_step,
            subscription: [
              :id,
              :updated_at,
              :promo_code_id,
            ],
            properties: [
              :id,
              :updated_at,
              :zipcode,
            ],
            promo_code: [
              :id,
              :updated_at,
            ]
  end

  authorize :user, optional: true
  authorize :changeset

  def can_sync?
    Rails.logger.info("Sync::User::Hubspot::Outbound::UpdatePolicy.can_sync?")
    Rails.logger.info("  has_external_id?=#{has_external_id?}")
    Rails.logger.info("  has_changed_attributes?=#{has_changed_attributes?}")
    Rails.logger.info("  enabled?=#{enabled?}")
    Rails.logger.info("changeset: #{changeset.inspect}")
    has_external_id? &&
    has_changed_attributes? &&
    enabled?
  end

  def has_external_id?
    record.hubspot_id.present?
  end

  def has_changed_attributes?
    !changeset.blank?
  end

  def enabled?
    ENV["HUBSPOT_OUTBOUND_DISABLED"] != "true"
  end
end
