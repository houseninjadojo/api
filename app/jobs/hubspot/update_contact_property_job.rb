class Hubspot::UpdateContactPropertyJob < ApplicationJob
  queue_as :default

  def perform(property)
    return unless has_hubspot_id?(property)

    id = property.user.hubspot_id
    params = params(property)

    Hubspot::Contact.update!(id, params)
  end

  def params(property)
    {
      address:   property.street_address1,
      address_2: property.street_address2,
      city:      property.city,
      state_new: property.state,
      zip:       property.zipcode,
    }
  end

  def has_hubspot_id?(property)
    property.user&.hubspot_id.present?
  end
end
