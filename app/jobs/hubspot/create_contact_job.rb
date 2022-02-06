class Hubspot::CreateContactJob < ApplicationJob
  sidekiq_options retry: 0
  queue_as :critical

  def perform(user)
    return if user.hubspot_id.present?

    params = params(user)
    contact = Hubspot::Contact.create_or_update(user.email, params)
    user.update!(
      hubspot_id:             contact.id,
      hubspot_contact_object: contact
    )
  end

  def params(user)
    {
      email:     user.email,
      firstname: user.first_name,
      lastname:  user.last_name,
      phone:     user.phone,
      zip:       user.requested_zipcode,
    }
  end
end
