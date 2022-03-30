class Hubspot::HandleWebhookJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound
  sidekiq_options retry: 0
  queue_as :default

  def perform(webhook_event)
    @webhook_event = webhook_event
    return if webhook_event.processed_at.present?
    @payload = webhook_event.payload
    process!
    webhook_event.update(processed_at: Time.now)
  end

  def process!
    if @payload.is_a?(Array)
      @payload.each do |item|
        process_payload_item(item)
      end
    else
      process_payload_item(@payload)
    end
  end

  def process_payload_item(item)
    hubspot_id = item["objectId"]
    attribute_value = item["propertyValue"]

    case item["subscriptionType"]
    when "contact.propertyChange"
      update_user(item)
      return
    when "contact.creation"
      user = User.find_by(hubspot_id: hubspot_id)
      if user.present?
        return # stop the ping pong
      else
        Hubspot::CreateUserFromContactJob.perform_later(hubspot_id)
      end
    when "contact.privacyDeletion"
      #
    when "contact.deletion"
      #
    when "deal.propertyChange"
      Hubspot::UpdateWorkOrderFromDealJob.perform_later(@webhook_event)
    when "deal.creation"
      work_order = WorkOrder.find_by(hubspot_id: hubspot_id)
      if work_order.present?
        return # no ping pong
      else
        Hubspot::CreateWorkOrderFromDealJob.perform_later(hubspot_id)
      end
    when "deal.deletion"
      #
    end
  end

  # def hubspot_id
  #   @payload["objectId"]
  # end

  # def attribute_value
  #   @payload["propertyValue"]
  # end

  def model_and_attribute(item)
    case item["propertyName"]
    when "email"
      return [User, :email]
    when "phone"
      return [User, attribute: :phone_number]
    when "address"
      return [Property, attribute: :street_address1]
    when "city"
      return [Property, attribute: :city]
    when "state"
      return [Property, attribute: :state]
    when "zip"
      return [Property, attribute: :zipcode]
    when "firstname"
      return [User, attribute: :first_name]
    when "lastname"
      return [User, attribute: :last_name]
    when "mobilephone"
      #
    when "lifecyclestage"
      #
    end
    []
  end

  def update_user(item)
    hubspot_id = item["objectId"]
    attribute_value = item["propertyValue"]
    model, attribute = model_and_attribute(item)

    if model.nil?
      return
    end

    resource = model.find_by(hubspot_id: hubspot_id)
    resource.update_from_service("hubspot", { attribute => attribute_value })
  end
end
