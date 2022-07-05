class Sync::Subscription::Stripe::Outbound::DeleteJob < Sync::BaseJob
  queue_as :default

  attr_accessor :resource

  def perform(resource)
    @resource = resource
    return unless policy.can_sync?

    # delete
    response = Stripe::Subscription.delete(resource.stripe_id)

    # update subscription
    resource.update!(
      status: response.status,
      canceled_at: epoch_to_datetime(response.canceled_at),
    )
  end

  def policy
    Sync::PaymentMethod::Stripe::Outbound::DeletePolicy.new(
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
