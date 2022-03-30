class Hubspot::HandleWebhookJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound
  sidekiq_options retry: 0
  queue_as :default

  def perform(webhook_event)
    return if webhook_event.processed_at.present?
    @payload = webhook_event.payload
    case @payload["subscriptionId"]
    when "contact.propertyChange"
      update_user
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
      Hubspot::UpdateWorkOrderFromDealJob.perform_later(webhook_event)
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
    webhook_event.update(processed_at: Time.now)
  end

  def hubspot_id
    @payload["objectId"]
  end

  def attribute_value
    @payload["propertyValue"]
  end

  def model_and_attribute
    case @payload["propertyName"]
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

  def update_user
    model, attribute = model_and_attribute

    if model.nil?
      webhook_event.update(processed_at: Time.now)
      return
    end

    resource = model.find_by(hubspot_id: hubspot_id)
    resource.update_from_service("hubspot", { attribute => attribute_value })
    webhook_event.update(processed_at: Time.now)
  end

  # # "subscriptionType"=>"contact.propertyChange"
  # #
  # # @return {User|WorkOrder}
  # def model_from_payload
  #   case @payload["subscriptionId"].split(".").first
  #   when "contact"
  #     return User
  #   when "deal"
  #     return WorkOrder
  #   end
  # end
end
