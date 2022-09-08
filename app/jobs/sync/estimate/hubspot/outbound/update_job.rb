class Sync::Estimate::Hubspot::Outbound::UpdateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :estimate, :changeset

  def perform(property, changeset)
    @changeset = changeset
    @estimate = estimate
    return unless policy.can_sync?

    # Hubspot::Contact.update!(property.user.hubspot_id, params)
  end

  def params
    {
      # address: property.street_address1,
      # address_2: property.street_address2,
      # city: property.city,
      # state_new: state_name,
      # zip: property.zipcode,
    }
  end

  def policy
    Sync::Estimate::Hubspot::Outbound::UpdatePolicy.new(
      estimate,
      changeset: changeset
    )
  end
end
