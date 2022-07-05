class Sync::PaymentMethod::Stripe::Outbound::CreateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :resource

  def perform(resource)
    @resource = resource
    return unless policy.can_sync?

    # Match payment method
    if matched_card.present?
      payment_method = matched_card
    else
      # Create Payment Method
      # @see https://stripe.com/docs/api/payment_methods/create
      payment_method = Stripe::PaymentMethod.create(params, {
        idempotency_key: idempotency_key,
        proxy: Rails.secrets.dig(:vgs, :outbound, :proxy_url)
      })
      # Attach Payment Method to Customer
      # @see https://stripe.com/docs/api/payment_methods/attach
      Stripe::PaymentMethod.attach(payment_method.id, {
        customer: resource.user.stripe_id
      })
    end
    resource.update!(
      stripe_token: payment_method.id,
      last_four: payment_method.card.last4,
    )
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
    Sync::PaymentMethod::Stripe::Outbound::CreatePolicy.new(
      resource
    )
  end

  def idempotency_key
    Digest::SHA256.hexdigest("#{resource.id}#{resource.updated_at.to_i}")
  end

  def matched_card
    @matched_card ||= begin
      payment_methods = Stripe::Customer.list_payment_methods(resource.user.stripe_id, { type: 'card' })
      payment_methods.data.find { |pm| pm.card.last4 == resource.card_number&.last(4) }
    end
  end
end
