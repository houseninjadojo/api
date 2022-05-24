class Arrivy::Webhook::IngestJob < ApplicationJob
  queue_as :default

  attr_accessor :webhook_event

  def perform(webhook_event)
    return if webhook_event.processed_at.present?
    @webhook_event = webhook_event

    # @todo
  end

  private

  def arrivy_event
    @arrivy_event ||= Arrivy::Event.new(@webhook_event.payload)
  end
end
