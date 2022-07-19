class CreditCards::CreateAndAttachJob < ApplicationJob
  queue_as :default

  attr_accessor :resource

  def perform(resource)
    @resource = resource
    return unless policy.can_sync?

    begin
      create_stripe_payment_method
      attach_stripe_payment_method
    rescue Stripe::CardError => e
      resource.errors.add(:base, e.message)
    rescue
      resource.errors.add(:base, "Something went wrong. Please try again.")
    end
    resource
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
        # house_ninja_id: resource.id,
      },
    }
  end

  def policy
    Sync::CreditCard::Stripe::Outbound::CreatePolicy.new(
      resource
    )
  end

  def create_stripe_payment_method
    # Create Payment Method
    # @see https://stripe.com/docs/api/payment_methods/create
    @stripe_payment_method = Stripe::PaymentMethod.create(params, {
      idempotency_key: idempotency_key,
      proxy: Rails.secrets.dig(:vgs, :outbound, :proxy_url)
    })
  end

  def attach_stripe_payment_method
    # Attach Payment Method to Customer
    # @see https://stripe.com/docs/api/payment_methods/attach
    Stripe::PaymentMethod.attach(payment_method.id, {
      customer: resource.user.stripe_id
    })
  end

  def idempotency_key
    Digest::SHA256.hexdigest("#{resource.card_number}_#{resource.exp_month}_#{resource.exp_year}_#{resource.cvv}")
  end

  def matched_card
    @matched_card ||= begin
      payment_methods = Stripe::Customer.list_payment_methods(resource.user&.stripe_id, { type: 'card' })
      payment_methods.data.find { |pm| pm.card.last4 == resource.card_number&.last(4) }
    end
  end
end
