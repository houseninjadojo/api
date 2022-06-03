class Sync::Property::Arrivy::OutboundJob < ApplicationJob
  queue_as :default

  attr_accessor :property, :changed_attributes

  def perform(property, changed_attributes)
    @changed_attributes = changed_attributes
    @property = property
    return unless policy.can_sync?

    customer = Arrivy::Customer.find(property.user&.arrivy_id)
    params.each do |key, val|
      customer.instance_variable_set("@#{key}", val)
    end
    customer.save
  end

  def params
    {
      # id: property.user&.arrivy_id,
      address_line_1: property.street_address1,
      address_line_2: property.street_address2,
      city: property.city,
      state: property.state,
      zipcode: property.zipcode,
    }
  end

  def policy
    Sync::Property::Arrivy::OutboundPolicy.new(
      property,
      changed_attributes: changed_attributes
    )
  end
end
