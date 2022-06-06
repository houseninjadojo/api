class Sync::Property::Hubspot::Outbound::CreateJob < ApplicationJob
  queue_as :default

  attr_accessor :property

  def perform(property)
    @property = property
    return unless policy.can_sync?

    Hubspot::Contact.update!(property.user.hubspot_id, params)
  end

  def params
    {
      address: property.street_address1,
      address_2: property.street_address2,
      city: property.city,
      state_new: state_name,
      zip: property.zipcode,
    }
  end

  def policy
    Sync::Property::Hubspot::Outbound::CreatePolicy.new(
      property
    )
  end

  def state_name
    StateNames.abbreviations[property.state] if property&.state.present?
  end
end
