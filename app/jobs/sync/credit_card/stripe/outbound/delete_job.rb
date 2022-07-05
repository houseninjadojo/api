class Sync::CreditCard::Stripe::Outbound::DeleteJob < Sync::BaseJob
  queue_as :default

  attr_accessor :resource

  def perform(resource)
    @resource = resource
    return unless policy.can_sync?

    # Detach
    Stripe::PaymentMethod.detach(resource.stripe_id)

    # Remove identifier if not deleted
    unless resource.reload.destroyed?
      resource.update!(stripe_token: nil)
    end
  end

  def policy
    Sync::CreditCard::Stripe::Outbound::DeletePolicy.new(
      resource
    )
  end
end
