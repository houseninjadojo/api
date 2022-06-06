class InvalidSubscriptionParamsException < StandardError; end

# @todo
# this whole file feels excessive

class Stripe::CreateSubscriptionJob < ApplicationJob
  discard_on InvalidSubscriptionParamsException
  queue_as :default

  def perform(subscription)
    return unless can_run_this_job?(subscription)

    params = params(subscription)
    response = Stripe::Subscription.create(params)

    response_params = response_params(response)
    subscription.update!(response_params)
    Hubspot::SetContactCurrentJob.perform_later(subscription.user)
  end

  def params(subscription)
    {
      collection_method: "charge_automatically",
      customer: customer_id(subscription),
      default_payment_method: payment_method_token(subscription),
      items: [
        { price: price_id(subscription) },
      ],
      promotion_code: promo_code(subscription),
    }
  end

  def response_params(response)
    {
      stripe_subscription_id: response .id,
      current_period_start: epoch_to_datetime(response.current_period_start),
      current_period_end: epoch_to_datetime(response.current_period_end),
      trial_start: epoch_to_datetime(response.trial_start),
      trial_end: epoch_to_datetime(response.trial_end),
      status: response.status,
    }
  end

  def can_run_this_job?(subscription)
    unless subscription_id(subscription).blank?
      raise InvalidSubscriptionParamsException.new "subscription id=#{subscription.id} already has a stripe_subscription_id=#{subscription_id(subscription)}"
      return false
    end

    if price_id(subscription).blank?
      raise InvalidSubscriptionParamsException.new "subscription_plan.id=#{subscription.subscription_plan.try(:id)} has no stripe_price_id"
      return false
    end

    if customer_id(subscription).blank?
      raise InvalidSubscriptionParamsException.new "user.id=#{subscription.user.try(:id)} has no stripe_id"
      return false
    end

    if payment_method_token(subscription).blank?
      raise InvalidSubscriptionParamsException.new "payment_method.id=#{subscription.payment_method.try(:id)} has no stripe_token"
      return false
    end

    return true
  end

  def subscription_id(subscription)
    subscription.stripe_subscription_id
  end

  def price_id(subscription)
    subscription.subscription_plan.try(:stripe_price_id)
  end

  def customer_id(subscription)
    subscription.user.try(:stripe_id)
  end

  def payment_method_token(subscription)
    subscription.payment_method.try(:stripe_token)
  end

  def promo_code(subscription)
    subscription.promo_code.try(:stripe_id)
  end

  def epoch_to_datetime(epoch)
    return nil if epoch.blank?
    Time.at(epoch)
  end
end
