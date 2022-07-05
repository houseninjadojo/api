class Sync::Webhook::ArrivyJob < ApplicationJob
  queue_as :default

  attr_accessor :webhook_event

  def perform(webhook_event)
    return if webhook_event.processed_at.present?
    @webhook_event = webhook_event

    return unless policy.can_sync?

    webhook_event.update!(payload: payload)

    Sync::WorkOrder::Arrivy::Inbound::UpdateJob.perform_now(webhook_event)
  end

  def policy
    Sync::Webhook::ArrivyPolicy.new(webhook_event)
  end

  def arrivy_event
    @arrivy_event ||= Arrivy::Event.new(webhook_event.payload)
  end

  def payload
    if arrivy_event.payload.is_a?(String)
      begin
        JSON.parse(arrivy_event.payload)
      rescue
        arrivy_event.payload
      end
    else
      arrivy_event.payload
    end
  end
end
