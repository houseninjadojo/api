class Sync::User::Intercom::Outbound::UpdatePolicy < ApplicationPolicy
  class Changeset < TreeDiff
    # observe :email,
    observe :first_name,
            :last_name,
            :phone_number
  end

  authorize :user, optional: true
  authorize :changeset

  def can_sync?
    has_external_id? &&
    has_changed_attributes? &&
    should_sync? &&
    enabled?
  end

  def has_external_id?
    record.intercom_id.present?
  end

  def has_changed_attributes?
    !changeset.blank?
  end

  def should_sync?
    # we want to hold on creating intercom contacts until
    # the customer is subscribed
    record.is_subscribed?
  end

  def enabled?
    ENV["INTERCOM_OUTBOUND_DISABLED"] != "true"
  end
end
