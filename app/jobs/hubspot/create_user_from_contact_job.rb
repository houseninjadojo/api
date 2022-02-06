class Hubspot::CreateUserFromContactJob < ApplicationJob
  queue_as :default

  def perform(hubspot_id)
    contact = Hubspot::Contact.find_by_vid(hubspot_id)
    attributes = map_contact_attributes(contact)

    # @todo
    # don't create anything yet
    #
    # User.find_or_create_by!(attributes)
  end

  def map_contact_attributes(contact)
    {
      email:        contact.email,
      first_name:   contact.firstname,
      last_name:    contact.lastname,
      phone_number: contact.phone,

      hubspot_id:             contact.id,
      hubspot_contact_object: contact,
    }
  end
end
