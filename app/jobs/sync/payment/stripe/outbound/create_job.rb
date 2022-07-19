class Sync::Payment::Stripe::Outbound::CreateJob < Sync::BaseJob
  attr_accessor :resource

  def perform(resource)
    @resource = resource
    return unless policy.can_sync?

    # We are hijacking this action to instead create a
    # payment through paying a stripe invoice
    pay_invoice!
  end

  def policy
    Sync::Payment::Stripe::Outbound::CreatePolicy.new(
      resource
    )
  end

  def idempotency_key
    Digest::SHA256.hexdigest(resource.id)
  end

  def pay_invoice!
    invoice = resource.invoice
    user = resource.user || invoice.user
    return if invoice.nil?

    ##
    payment_method = user.default_payment_method&.stripe_token
    ##

    paid_invoice = Stripe::Invoice.pay(
      invoice.stripe_id,
      { payment_method: payment_method },
      { idempotency_key: idempotency_key }
    )

    ActiveRecord::Base.transaction do
      resource.update!(
        stripe_id: paid_invoice.charge
      )
      paid_at = paid_invoice&.status_transitions&.paid_at
      invoice.update!(
        paid_at: (paid_at.present? ? Time.at(paid_at) : nil),
        payment_attempted_at: Time.current,
        status: paid_invoice.status,
        stripe_object: paid_invoice
      )
    end
  end
end
