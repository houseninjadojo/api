class Users::CreateIntestedUserJob < ApplicationJob
  queue_as :default

  def perform(email:, zipcode:)
    contact = Hubspot::Contact.create_or_update(email, {
      zip: zipcode,
      contact_type: ContactType::SERVICE_AREA_REQUESTED,
    })
  end
end
