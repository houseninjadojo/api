class Sync::Payment::Stripe::Inbound::UpdateJob < Sync::BaseJob
  attr_accessor :webhook_event

  def perform(webhook_event)
    @webhook_event = webhook_event

    return unless policy.can_sync?

    payment.update!(params)

    webhook_event.update!(processed_at: Time.now)
  end

  def policy
    Sync::Payment::Stripe::Inbound::UpdatePolicy.new(
      stripe_event,
      webhook_event: webhook_event
    )
  end

  def params
    {
      amount: stripe_object.amount,
      description: stripe_object.description,
      paid: stripe_object.paid,
      refunded: stripe_object.refunded,
      statement_descriptor: stripe_object.statement_descriptor,
      status: stripe_object.status,

      invoice: invoice,
      payment_method: payment_method,
      user: user,

      stripe_object: stripe_object.to_json,
    }.compact
  end

  def payment
    @payment ||= Payment.find_by(stripe_id: stripe_object.id)
  end

  def invoice
    @invoice ||= Invoice.find_by(stripe_id: stripe_object.invoice)
  end

  def user
    @user ||= User.find_by(stripe_id: stripe_object.customer)
  end

  def payment_method
    @payment_method ||= PaymentMethod.find_by(stripe_token: stripe_object.payment_method)
  end

  def stripe_event
    @resource ||= Stripe::Event.construct_from(webhook_event.payload)
  end

  def stripe_object
    stripe_event.data.object
  end
end
