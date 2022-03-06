class Hubspot::SetContactCurrentJob < ApplicationJob
  queue_as :default

  def perform(user)
    id = user.hubspot_id
    params = {
      customer_type: "Current"
    }

    Hubspot::Contact.update!(id, params)
  end
end
