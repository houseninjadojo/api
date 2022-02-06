class Stripe::HandleWebhookJob < ApplicationJob
  sidekiq_options retry: 0
  queue_as :default

  def perform(webhook_job)
    return if webhook_job.processed_at.present?
    @payload = webhook_job.payload

    case event
    when "customer.updated"
      user = User.find_by(stripe_customer_id: stripe_id)
      user.update_from_service("stripe", user_attributes)
      webhook_job.update(processed_at: Time.now)
    when "customer.created"
      user = User.find_by(stripe_customer_id: stripe_id)
      if user.present?
        webhook_job.update(processed_at: Time.now)
        return
      end
      user = User.new(user_attributes)
      user.stripe_customer_id = stripe_id
      # @todo
      # enable this when ready
      # user.save!
      # webhook_job.update(processed_at: Time.now)
    end
  end

  def event
    @payload["type"]
  end

  def object
    @payload["data"]["object"]
  end

  def stripe_id
    object["id"]
  end

  def user_attributes
    first_name, last_name = split_name
    {
      email:        object["email"],
      phone_number: object["phone"],
      first_name:   first_name,
      last_name:    last_name,
    }
  end

  def split_name
    return [] if object["name"].blank?
    object["name"].split[" "]
  end
end
