class Sync::WorkOrder::Hubspot::Inbound::CreateJob < Sync::BaseJob
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

  def user
    User.find_by(hubspot_id: hubspot_contact&.id)
  end

  def deal_params
    {
      property: user&.default_property,
      description: deal[:dealname],
      hubspot_id: deal[:hs_object_id],
      status: WorkOrderStatus.find_by(hubspot_id: deal[:dealstage]),
      created_at: Time.at(deal[:createdate]&.to_i / 1000),
      # updated_at: Time.at(deal[:hs_lastmodifieddate]&.to_i / 1000),

      scheduled_date: timestamps[:scheduled_date],
      scheduled_time: timestamps[:scheduled_time],
      scheduled_window_start: timestamps[:scheduled_window_start],
      scheduled_window_end: timestamps[:scheduled_window_end],
      walkthrough_date: timestamps[:walkthrough_date],
      walkthrough_time: timestamps[:walkthrough_time],
    }
  end

  def hubspot_contact
    @hubspot_contacts ||= Hubspot::Association.all(deal[:hs_object_id], Hubspot::Association::DEAL_TO_CONTACT) || []
    @hubspot_contacts.first
  end

  def walkthrough_engagement
    @engagement ||= begin
      engagements = Hubspot::Engagement.find_by_association(user.hubspot_id&.to_i, 'CONTACT')
      engagements.find { |e| e.engagement["type"] == "MEETING" && e.metadata["title"] == "House Ninja Home Walkthrough" }
    end
  end

  def timestamps
    return {} unless deal[:dealname].match(/Home Walkthrough\: /).present?
    start_datetime = Time.at(walkthrough_engagement.metadata["startTime"] / 1000)
    end_datetime = Time.at(walkthrough_engagement.metadata["endTime"] / 1000)
    time_window = "#{start_datetime.strftime("%I:%M %p")} - #{end_datetime.strftime("%I:%M %p")}"
    {
      scheduled_date: start_datetime.strftime("%m/%d/%Y"),
      scheduled_time: time_window,
      scheduled_window_start: start_datetime,
      scheduled_window_end: end_datetime,
      walkthrough_date: start_datetime,
      walkthrough_time: time_window,
    }
  end
end
