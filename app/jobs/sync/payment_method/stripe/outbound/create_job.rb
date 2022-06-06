class Sync::PaymentMethod::Stripe::Outbound::CreateJob < ApplicationJob
  queue_as :default

  attr_accessor :resource

  def perform(resource)
    @resource = resource
    return unless policy.can_sync?

    # Create Payment Method
    # @see https://stripe.com/docs/api/payment_methods/create
    payment_method = Stripe::PaymentMethod.create(params, {
      proxy: Rails.secrets.dig(:vgs, :outbound, :proxy_url)
    })
    resource.update!(stripe_token: payment_method.id)

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
      }
    }
  end

  def policy
    Sync::PaymentMethod::Stripe::Outbound::CreatePolicy.new(
      resource
    )
  end
end
