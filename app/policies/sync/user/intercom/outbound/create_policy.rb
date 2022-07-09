class Sync::User::Intercom::Outbound::CreatePolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    !has_external_id? &&
    should_sync?
  end

  def has_external_id?
    record.intercom_id.present?
  end

  def should_sync?
    # we want to hold on creating intercom contacts until
    # the customer is subscribed
    record.is_subscribed?
  end
end
