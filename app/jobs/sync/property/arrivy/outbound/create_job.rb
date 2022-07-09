class Sync::Property::Arrivy::Outbound::CreateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :property

  def perform(property)
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
      address_line_1: property.street_address1,
      address_line_2: property.street_address2,
      city: property.city,
      state: property.state,
      zipcode: property.zipcode,
    }
  end

  def policy
    Sync::Property::Arrivy::Outbound::CreatePolicy.new(
      property
    )
  end
end
