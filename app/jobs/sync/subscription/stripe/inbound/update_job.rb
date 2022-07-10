class Sync::Subscription::Stripe::Inbound::UpdateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :webhook_event

  def perform(webhook_event)
    @webhook_event = webhook_event

    return unless policy.can_sync?

    subscription.update!(params)

    webhook_event.update!(processed_at: Time.now)
  end

  def policy
    Sync::Subscription::Stripe::Inbound::UpdatePolicy.new(
      stripe_event,
      webhook_event: webhook_event
    )
  end

  def stripe_event
    @resource ||= Stripe::Event.construct_from(webhook_event.payload)
  end

  def stripe_object
    stripe_event.data.object
  end

  def subscription
    @subscription ||= Subscription.find_by(stripe_id: stripe_object.id) if stripe_object&.id.present?
  end

  def params
    {
      status: stripe_object.status,

      stripe_object: stripe_object.to_json,
    }.compact
  end
end
