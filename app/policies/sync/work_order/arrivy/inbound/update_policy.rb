class Sync::WorkOrder::Arrivy::Inbound::UpdatePolicy < ApplicationPolicy
  authorize :user, optional: true
  authorize :webhook_event

  def can_sync?
    webhook_is_unprocessed? &&
    has_external_id? &&
    has_work_order? &&
    is_valid_task_status? &&
    has_dates_and_times?
  end

  def has_external_id?
    record.hubspot_id.present?
  end

  def has_work_order?
    WorkOrder.where(arrivy_id: record.arrivy_id).or(
      WorkOrder.where(hubspot_id: record.hubspot_id)
    ).first.present?
  end

  def is_valid_task_status?
    Arrivy::Event::TYPES::ALL.include?(record.event_type)
  end

  def has_dates_and_times?
    [
      record&.scheduled_date.present?,
      record&.scheduled_time.present?,
      # record&.starting_at.present?,
      # record&.ending_at.present?
    ].any?
  end

  def webhook_is_unprocessed?
    !webhook_event.processed?
  end
end
