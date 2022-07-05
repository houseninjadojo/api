class Sync::Property::Hubspot::Outbound::UpdateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :property, :changeset

  def perform(property, changeset)
    @changeset = changeset
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
    Sync::Property::Hubspot::Outbound::UpdatePolicy.new(
      property,
      changeset: changeset
    )
  end

  def state_name
    StateNames.abbreviations[property.state] if property&.state.present?
  end
end
