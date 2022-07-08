class Sync::WorkOrder::Arrivy::Outbound::CreatePolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    !has_external_id? &&
    has_start_datetime?
  end

  def has_external_id?
    record.arrivy_id.present?
  end

  def has_start_datetime?
    record.scheduled_window_start.present?
  end
end
