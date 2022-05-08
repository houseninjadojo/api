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
    if is_deal_batch?
      item = @payload.find { |i| i["subscriptionType"] == "deal.creation" }
      process_payload_item(item)
    else
      @payload.each do |item|
        process_payload_item(item)
      end
    end
  end

  def process_payload_item(item)
    hubspot_id = item["objectId"]
    attribute_value = item["propertyValue"]

    case item["subscriptionType"]
    when "contact.propertyChange"
      Hubspot::Webhook::Handler::Contact::PropertyChangeJob.perform_later(item, @webhook_event)
      return
    when "contact.creation"
      Hubspot::Webhook::Handler::Contact::CreationJob.perform_later(item, @webhook_event)
      return
    when "contact.privacyDeletion"
      #
    when "contact.deletion"
      #
    when "deal.propertyChange"
      Hubspot::Webhook::Handler::Deal::PropertyChangeJob.perform_later(item, @webhook_event)
      return
    when "deal.creation"
      Hubspot::Webhook::Handler::Deal::CreationJob.perform_later(hubspot_id, @webhook_event)
      return
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

  # def model_and_attribute(item)
  #   case item["propertyName"]
  #   when "email"
  #     return [User, :email]
  #   when "phone"
  #     return [User, attribute: :phone_number]
  #   when "address"
  #     return [Property, attribute: :street_address1]
  #   when "city"
  #     return [Property, attribute: :city]
  #   when "state"
  #     return [Property, attribute: :state]
  #   when "zip"
  #     return [Property, attribute: :zipcode]
  #   when "firstname"
  #     return [User, attribute: :first_name]
  #   when "lastname"
  #     return [User, attribute: :last_name]
  #   when "mobilephone"
  #     #
  #   when "lifecyclestage"
  #     #
  #   end
  #   []
  # end

  # def update_user(item)
  #   hubspot_id = item["objectId"]
  #   attribute_value = item["propertyValue"]
  #   model, attribute = model_and_attribute(item)

  #   if model.nil?
  #     return
  #   end

  #   resource = model.find_by(hubspot_id: hubspot_id)
  #   resource.update_from_service("hubspot", { attribute => attribute_value })
  # end

  # when a deal is created, hubspot sends several `propertyChange` events,
  # one `creation` event, and 0 other events. We can use this particularity
  # as a kind of "webhook payload signature".
  def is_deal_batch?
    @payload.pluck("subscriptionType").uniq == ["deal.propertyChange", "deal.creation"]
  end
end
