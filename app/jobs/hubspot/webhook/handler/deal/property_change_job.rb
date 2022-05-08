class Hubspot::Webhook::Handler::Deal::PropertyChangeJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound
  sidekiq_options retry: 0
  queue_as :default

  def perform(webhook_entry, webhook_event)
    @entry = webhook_entry

    unless conditions_met?
      # create a work order if this one does not exist yet
      if work_order.nil?
        Hubspot::CreateWorkOrderFromDealJob.perform_later(hubspot_id)
      end
      return
    end

    work_order.update!(attribute => attribute_value)

    webhook_event.update!(processed_at: Time.now)
  end

  private

  def conditions_met?
    [
      webhook_event.processed_at.blank?,
      hubspot_id.present?,
      attribute.present?,
      attribute_value.present?,
      work_order.present?,
    ].all?
  end

  def hubspot_id
    @entry["objectId"]
  end

  def attribute
    @entry["propertyName"]
  end

  def attribute_value
    @entry["propertyValue"]
  end

  def work_order
    @work_order ||= WorkOrder.find_by(hubspot_id: hubspot_id)
  end
end
