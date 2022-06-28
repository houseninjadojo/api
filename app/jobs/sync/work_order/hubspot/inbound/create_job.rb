class Sync::WorkOrder::Hubspot::Inbound::CreateJob < ApplicationJob
  queue_as :default

  attr_accessor :webhook_entry, :webhook_event

  delegate :resource_klass, :attribute_name, :attribute_value, to: :entry

  def perform(webhook_event, webhook_entry)
    @webhook_entry = webhook_entry
    @webhook_event = webhook_event

    return unless policy.can_sync?

    resource_klass.create!(deal_params)

    webhook_event.update!(processed_at: Time.now)
  end

  def policy
    Sync::WorkOrder::Hubspot::Inbound::CreatePolicy.new(
      webhook_entry,
      webhook_event: webhook_event
    )
  end

  def payload
    Hubspot::Webhook::Payload.new(webhook_event)
  end

  def entry
    Hubspot::Webhook::Entry.new(webhook_event, webhook_entry)
  end

  def params
    payload.as_params
  end

  def deal
    @deal ||= Hubspot::Deal.find(entry.hubspot_id)
  end

  def deal_params
    {
      user: User.find_by(hubspot_id: hubspot_contact&.id),
      description: deal[:dealname],
      hubspot_id: deal[:hs_object_id],
      status: WorkOrderStatus.find_by(hubspot_id: deal[:dealstage]),
      created_at: Time.at(deal[:createdate]&.to_i / 1000),
      # updated_at: Time.at(deal[:hs_lastmodifieddate]&.to_i / 1000),
    }
  end

  def hubspot_contact
    @hubspot_contacts ||= Hubspot::Association.all(deal[:hs_object_id], Hubspot::Association::DEAL_TO_CONTACT) || []
    @hubspot_contacts.first
  end
end
