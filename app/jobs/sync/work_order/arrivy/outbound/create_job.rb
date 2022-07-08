class Sync::WorkOrder::Arrivy::Outbound::CreateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :work_order

  def perform(work_order)
    @work_order = work_order
    return unless policy.can_sync?

    task = Arrivy::Task.new(params).create
    work_order.update!(arrivy_id: task.id)
  end

  def params
    {
      title: work_order.description,
      start_datetime: work_order.scheduled_window_start&.iso8601,
      end_datetime: work_order.scheduled_window_end&.iso8601,
      customer_id: work_order.user&.arrivy_id,
      external_id: work_order.id,

      # if walkthrough
      # template_id: 5989917552803840
    }
  end

  def policy
    Sync::WorkOrder::Arrivy::Outbound::CreatePolicy.new(
      work_order
    )
  end
end
