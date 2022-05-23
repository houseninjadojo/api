class Hubspot::Webhook::Handler::Contact::CreationJob < ApplicationJob
  queue_as :default

  def perform(webhook_entry, webhook_event)
    @entry = webhook_entry
    return unless conditions_met?

    # @todo
    # don't create anything yet
    #
    # User.find_or_create_by!(user_attributes_from_contact)
    #
    # webhook_event.update!(processed_at: Time.now)
  end

  private

  def conditions_met?
    [
      enabled?,
      webhook_event.processed_at.blank?,
      hubspot_id.present?,
      user.nil?,
      contact.present?,
    ].all?
  end

  def hubspot_id
    @entry["objectId"]
  end

  def user
    @user ||= User.find_by(hubspot_id: hubspot_id)
  end

  def contact
    @contact ||= Hubspot::Contact.find_by_vid(hubspot_id)
  end

  def user_attributes_from_contact
    {
      email:        contact.email,
      first_name:   contact.firstname,
      last_name:    contact.lastname,
      phone_number: contact.phone,

      hubspot_id:             contact.id,
      hubspot_contact_object: contact,
    }
  end

  def enabled?
    ENV["HUBSPOT_WEBHOOK_DISABLED"] != "true"
  end
end
