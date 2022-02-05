class Stripe::HandleWebhookJob < ApplicationJob
  queue_as :default

  def perform(webhook_job)
    # Do something later
  end
end
