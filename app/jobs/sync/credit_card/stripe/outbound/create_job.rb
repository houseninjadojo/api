class Sync::CreditCard::Stripe::Outbound::CreateJob < ApplicationJob
  queue_as :default

  attr_accessor :resource

  def perform(resource)
    @resource = resource
    return unless policy.can_sync?

    # Create Payment Method
    # @see https://stripe.com/docs/api/payment_methods/create
    payment_method = Stripe::PaymentMethod.create(params, {
      idempotency_key: idempotency_key,
      proxy: Rails.secrets.dig(:vgs, :outbound, :proxy_url)
    })
    resource.update!(
      stripe_token: payment_method.id,
      last_four: payment_method.card.last4,
    )

    # Attach Payment Method to Customer
    # @see https://stripe.com/docs/api/payment_methods/attach
    Stripe::PaymentMethod.attach(resource.stripe_token, {
      customer: resource.user.stripe_id
    })
  end

  def params
    # @todo
    # assuming this is a card for now, but it should be more generic
    {
      type: 'card',
      card: {
        number: resource.card_number,
        exp_month: resource.exp_month,
        exp_year: resource.exp_year,
        cvc: resource.cvv,
      },
      metadata: {
        house_ninja_id: resource.id,
      },
    }
  end

  def policy
    Sync::CreditCard::Stripe::Outbound::CreatePolicy.new(
      resource
    )
  end

  def idempotency_key
    Digest::SHA256.hexdigest("#{resource.id}#{resource.updated_at.to_i}")
  end
end
