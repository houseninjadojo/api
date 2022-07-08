class Sync::Property::Arrivy::Outbound::UpdateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :property, :changeset

  def perform(property, changeset)
    @changeset = changeset
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
    Sync::Property::Arrivy::Outbound::UpdatePolicy.new(
      property,
      changeset: changeset
    )
  end
end
