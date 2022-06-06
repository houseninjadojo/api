class Sync::User::Arrivy::Outbound::CreatePolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    !has_external_id? && should_sync?
  end

  def has_external_id?
    record.arrivy_id.present?
  end

  def should_sync?
    # we want to hold on creating arrivy contacts until
    # the customer is subscribed
    record.is_subscribed?
  end
end
