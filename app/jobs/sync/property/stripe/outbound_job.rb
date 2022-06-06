class Sync::Property::Stripe::OutboundJob < ApplicationJob
  queue_as :default

  attr_accessor :property, :changed_attributes

  def perform(property, changed_attributes)
    @changed_attributes = changed_attributes
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
    Sync::Property::Stripe::OutboundPolicy.new(
      property,
      changed_attributes: changed_attributes
    )
  end
end
