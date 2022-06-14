class Hubspot::Webhook::Handler::Contact::PropertyChangeJob < ApplicationJob
  queue_as :default

  def perform(webhook_entry, webhook_event)
    @entry = webhook_entry
    return unless conditions_met?

    resource.update!(attribute => attribute_value)

    webhook_event.update!(processed_at: Time.now)
  end

  private

  def conditions_met?
    [
      enabled?,
      webhook_event.processed_at.blank?,
      hubspot_id.present?,
      attribute_value.present?,
      model.present?,
      attribute.present?,
      resource.present?,
    ].all?
  end

  def hubspot_id
    @entry["objectId"]
  end

  def attribute_value
    @entry["propertyValue"]
  end

  def model
    @model ||= model_and_attribute.first
  end

  def attribute
    @attribute ||= model_and_attribute.last
  end

  def resource
    @resource ||= model.find_by(hubspot_id: hubspot_id)
  end

  def model_and_attribute
    case @entry["propertyName"]
    # when "email"
      # return [User, :email]
    # when "phone"
      # return [User, attribute: :phone_number]
    # when "address"
      # return [Property, attribute: :street_address1]
    # when "city"
      # return [Property, attribute: :city]
    # when "state"
      # return [Property, attribute: :state]
    # when "zip"
      # return [Property, attribute: :zipcode]
    # when "firstname"
      # return [User, attribute: :first_name]
    # when "lastname"
      # return [User, attribute: :last_name]
    when "mobilephone"
      #
    when "lifecyclestage"
      #
    end
    []
  end

  def enabled?
    ENV["HUBSPOT_WEBHOOK_DISABLED"] != "true"
  end
end
