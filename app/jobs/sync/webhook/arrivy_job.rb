class Sync::Webhook::ArrivyJob < ApplicationJob
  queue_as :default

  attr_accessor :webhook_event

  def perform(webhook_event)
    return if webhook_event.processed_at.present?
    @webhook_event = webhook_event

    return unless policy.can_sync?

    Sync::WorkOrder::Arrivy::Inbound::UpdateJob.perform_now(webhook_event)
  end

  def policy
    Sync::Webhook::ArrivyPolicy.new(webhook_event)
  end
end
