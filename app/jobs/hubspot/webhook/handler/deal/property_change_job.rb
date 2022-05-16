class Hubspot::Webhook::Handler::Deal::PropertyChangeJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound
  sidekiq_options retry: 0
  queue_as :default

  attr_accessor :webhook_event, :webhook_entry

  def perform(webhook_entry, webhook_event)
    @webhook_entry = webhook_entry
    @webhook_event = webhook_event

    unless conditions_met?
      # create a work order, this one does not exist yet
      create_work_order if work_order.nil?
      return
    end

    update_attribute!

    webhook_event.update!(processed_at: Time.now)
  end

  private

  def entry
    webhook_entry
  end

  def conditions_met?
    [
      # webhook_event.processed_at.blank?,
      hubspot_id.present?,
      attribute.present?,
      attribute_value.present?,
      work_order.present?,
    ].all?
  end

  def hubspot_id
    entry["objectId"]
  end

  def attribute
    entry["propertyName"]
  end

  def attribute_value
    entry["propertyValue"]
  end

  def work_order
    @work_order ||= WorkOrder.find_by(hubspot_id: hubspot_id)
  end

  def invoice
    @invoice ||= Invoice.find_or_create_by(work_order: work_order)
  end

  def create_work_order
    Hubspot::Webhook::Handler::Deal::CreationJob.perform_later(
      webhook_entry,
      webhook_event
    )
  end

  def amount_in_cents
    return "0" if attribute_value.blank?
    Money.from_amount(attribute_value.to_f).fractional.to_s
  end

  def update_attribute!
    case attribute
    when "amount"
      invoice.update!(total: amount_in_cents)
      Hubspot::Deal::SyncLineItemsJob.perform_later(hubspot_id, invoice)
    when "closedate"
      #
    when "closed_lost_reason"
      #
    when "closed_won_reason"
      #
    when "createdate"
      work_order.update!(created_at: attribute_value)
    when "dealname"
      work_order.update!(description: attribute_value)
    when "dealstage"
      status = WorkOrderStatus.find_by(hubspot_id: attribute_value)
      work_order.update!(status: status)
      Hubspot::Deal::SyncLineItemsJob.perform_later(hubspot_id, invoice)
    when "dealtype"
      #
    when "description"
      #
    when "invoice_for_homeowner"
      invoice.update!(total: amount_in_cents)
      work_order.update!(homeowner_amount: amount_in_cents)
      Hubspot::Deal::SyncLineItemsJob.perform_later(hubspot_id, invoice)
    when "invoice_from_vendor"
      work_order.update!(vendor_amount: amount_in_cents)
      Hubspot::Deal::SyncLineItemsJob.perform_later(hubspot_id, invoice)
    when "invoice_notes"
      invoice.update!(description: attribute_value)
      Hubspot::Deal::SyncLineItemsJob.perform_later(hubspot_id, invoice)
    else
      Rails.logger.info("Unknown deal property: #{attribute}")
    end
  end
end
