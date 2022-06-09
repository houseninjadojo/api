class Sync::User::Hubspot::Outbound::UpdatePolicy < ApplicationPolicy
  class Changeset < TreeDiff
    observe :contact_type,
            :email,
            :first_name,
            :last_name,
            :phone_number,
            :requested_zipcode,
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
