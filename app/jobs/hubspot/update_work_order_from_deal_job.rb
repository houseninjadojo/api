class Hubspot::UpdateWorkOrderFromDealJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound
  sidekiq_options retry: 0
  queue_as :default

  def perform(webhook_event)
    ActiveSupport::Deprecation.warn(
      "`Hubspot::UpdateWorkOrderFromDealJob` is deprecated. " \
      "Use `Hubspot::Webhook::Handler::Deal::PropertyChangeJob` instead."
    )

    @webhook_event = webhook_event
    return if webhook_event.processed_at.present?

    # we already know this is a single event
    @payload = webhook_event.payload.first
    process!
    webhook_event.update!(processed_at: Time.now)
  end

  def process!
    @work_order = WorkOrder.find_by(hubspot_id: @payload["objectId"])
    if @work_order.nil?
      create_work_order
    else
      update_work_order!
    end
  end

  def create_work_order
    Hubspot::CreateWorkOrderFromDealJob.perform_later(@payload["objectId"])
  end

  def update_work_order!
    attribute = @payload["propertyName"]
    attribute_value = @payload["propertyValue"]
    @work_order.update!(attribute => attribute_value)
  end
end
