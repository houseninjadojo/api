class Sync::CreditCard::Stripe::Outbound::CreateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :resource

  # Perform the job by creating a payment method in Stripe and attaching it to the customer's account.
  # If a payment method with the same last 4 digits as the resource's card number already exists,
  # just touch the resource. Otherwise, create a new payment method and attach it to the customer,
  # and update the resource with the payment method's id and the last 4 digits of the card.
  #
  # @param resource [ActiveRecord::Base] the credit card resource to sync with Stripe
  # @return [ActiveRecord::Base] the credit card resource
  def perform(resource)
    @resource = resource
    return unless policy.can_sync?

    # Match payment method
    if matched_card.present?
      payment_method = matched_card
      resource.touch
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
      resource.update!(
        stripe_token: payment_method.id,
        last_four: payment_method.card.last4,
      )
    end
    resource
  end

  # Get the params for creating a payment method in Stripe.
  #
  # @return [Hash] the params for creating a payment method in Stripe
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

  # Get the policy for creating a payment method in Stripe.
  #
  # @return [Sync::CreditCard::Stripe::Outbound::CreatePolicy] the policy for creating a payment method in Stripe
  def policy
    Sync::CreditCard::Stripe::Outbound::CreatePolicy.new(
      resource
    )
  end

  # Get the idempotency key for the Stripe API request.
  #
  # @return [String] the idempotency key for the Stripe API request
  def idempotency_key
    Digest::SHA256.hexdigest("#{resource.id}#{resource.updated_at.to_i}")
  end

  # Get the payment method with the same last 4 digits as the resource's card number, if one exists.
  #
  # @return [Stripe::PaymentMethod, nil] the payment method with the same last 4 digits as the resource's card number, if one exists
  def matched_card
    @matched_card ||= begin
      payment_methods = Stripe::Customer.list_payment_methods(resource.user&.stripe_id, { type: 'card' })
      payment_methods.data.find { |pm| pm.card.last4 == resource.card_number&.last(4) }
    end
  end
end
