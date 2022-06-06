class Stripe::CancelSubscriptionJob < ApplicationJob
  queue_as :default

  def perform(subscription)
    return if subscription.stripe_id.blank?

    response = Stripe::Subscription.delete(subscription.stripe_id)

    response_params = response_params(response)
    subscription.update!(response_params)
  end

  def response_params(response)
    {
      status: response.status,
      canceled_at: epoch_to_datetime(response.canceled_at),
    }
  end

  def epoch_to_datetime(epoch)
    return nil if epoch.blank?
    Time.at(epoch)
  end
end
