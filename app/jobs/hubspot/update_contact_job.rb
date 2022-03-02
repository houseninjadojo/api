class Hubspot::UpdateContactJob < ApplicationJob
  queue_as :default

  def perform(user)
    id = user.hubspot_id
    params = contact_properties(user)

    Hubspot::Contact.update!(id, params)
  end

  def contact_properties(user)
    {
      email:     user.email,
      firstname: user.first_name,
      lastname:  user.last_name,
      phone:     user.phone_number,
    }
  end
end
