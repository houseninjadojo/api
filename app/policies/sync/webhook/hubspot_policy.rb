class Sync::Webhook::HubspotPolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    enabled? &&
    webhook_is_unprocessed?
  end

  # def has_handler?
  #   Sync::Webhook::StripeJob.new(record).handler.present?
  # end

  def webhook_is_unprocessed?
    !record.processed?
  end

  def enabled?
    ENV["HUBSPOT_WEBHOOK_DISABLED"] != "true"
  end
end
