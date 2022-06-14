class Sync::Webhook::ArrivyJob < ApplicationJob
  queue_as :default

  attr_accessor :webhook_event

  def perform(webhook_event)
    return if webhook_event.processed_at.present?
    @webhook_event = webhook_event

    return unless policy.can_sync?

    # @todo
  end

  def policy
    Sync::Webhook::ArrivyPolicy.new(webhook_event)
  end

  def arrivy_event
    @arrivy_event ||= Arrivy::Event.new(@webhook_event.payload)
  end
end
