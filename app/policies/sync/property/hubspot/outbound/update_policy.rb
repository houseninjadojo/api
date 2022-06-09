class Sync::Property::Hubspot::Outbound::UpdatePolicy < ApplicationPolicy
  class Changeset < TreeDiff
    observe :street_address1,
            :street_address2,
            :city,
            :state,
            :zipcode
  end

  authorize :user, optional: true
  authorize :changeset

  def can_sync?
    has_external_id? &&
    has_changed_attributes?
  end

  def has_external_id?
    record.user&.hubspot_id.present?
  end

  def has_changed_attributes?
    !changeset.blank?
  end
end
