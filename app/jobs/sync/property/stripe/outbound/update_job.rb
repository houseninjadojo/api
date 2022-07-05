class Sync::Property::Stripe::Outbound::UpdateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :property, :changeset

  def perform(property, changeset)
    @changeset = changeset
    @property = property
    return unless policy.can_sync?

    Stripe::Customer.update(property.user.stripe_id, params)
  end

  def params
    {
      address: {
        line1: property.street_address1,
        line2: property.street_address2,
        city: property.city,
        state: property.state,
        postal_code: property.zipcode,
      }
    }
  end

  def policy
    Sync::Property::Stripe::Outbound::UpdatePolicy.new(
      property,
      changeset: changeset
    )
  end
end
