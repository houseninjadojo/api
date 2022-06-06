class Sync::Subscription::Stripe::Outbound::CreateJob < ApplicationJob
  queue_as :default

  attr_accessor :resource

  def perform(resource)
    @resource = resource
    return unless policy.can_sync?

    begin
      subscription = Stripe::Subscription.create(params)
    rescue Stripe::StripeError => e
      Rails.logger.error("Stripe::Subscription.create failed: #{e.message}")
      return e # don't try updating a non-existent subscription
    end

    resource.update!(
      stripe_id: subscription.id,
      current_period_start: epoch_to_datetime(subscription.current_period_start),
      current_period_end: epoch_to_datetime(subscription.current_period_end),
      trial_start: epoch_to_datetime(subscription.trial_start),
      trial_end: epoch_to_datetime(subscription.trial_end),
      status: subscription.status,
    )
  end

  def params
    {
      collection_method: "charge_automatically",
      customer: resource.user.stripe_id,
      default_payment_method: resource.payment_method.stripe_id,
      items: [
        { price: resource.subscription_plan.stripe_price_id },
      ],
      promotion_code: resource.promo_code&.stripe_id,

      # ensure we get an error on payment failure
      # @see https://stripe.com/docs/api/subscriptions/create#create_subscription-payment_behavior
      payment_behavior: 'error_if_incomplete',
    }
  end

  def policy
    Sync::Subscription::Stripe::Outbound::CreatePolicy.new(
      resource
    )
  end

  def epoch_to_datetime(epoch)
    if epoch.present?
      Time.at(epoch)
    else
      nil
    end
  end
end
