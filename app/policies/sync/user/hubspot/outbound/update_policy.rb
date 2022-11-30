class Sync::User::Hubspot::Outbound::UpdatePolicy < ApplicationPolicy
  class Changeset < TreeDiff
    # observe :email,
    observe :contact_type,
            :customer_type,
            :first_name,
            :last_name,
            :phone_number,
            :onboarding_code,
            :onboarding_link,
            :onboarding_step,
            :requested_zipcode,
            :how_did_you_hear_about_us,
            subscription: [
              :id,
              :updated_at,
              :promo_code_id,
              :status,
              :stripe_object,
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
    if !Rails.env.test?
      Rails.logger.info("sync policy action=update user=#{record.id}", {
        policy: {
          resource: "user",
          service: "hubspot",
          direction: "outbound",
          action: "update",
          result: can_sync_result,
        },
        resource: {
          id: record&.id,
          type: "user",
        },
        factors: {
          has_external_id: has_external_id?,
          has_changed_attributes: has_changed_attributes?,
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
