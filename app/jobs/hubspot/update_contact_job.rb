class Hubspot::UpdateContactJob < ApplicationJob
  queue_as :default

  def perform(user)
    ActiveSupport::Deprecation.warn('use Sync::User::Hubspot::OutboundJob instead')

    id = user.hubspot_id
    params = contact_properties(user)

    Hubspot::Contact.update!(id, params)
  end

  def contact_properties(user)
    {
      contact_type: user.contact_type,
      email:        user.email,
      firstname:    user.first_name,
      lastname:     user.last_name,
      phone:        user.phone_number,
      zip:          user.requested_zipcode,

      onboarding_code: user.onboarding_code,
      onboarding_link: user.onboarding_link,
    }
  end
end
