class PushNotification::DeliverJob < ApplicationJob
  queue_as :default
  unique :until_executed

  def perform(notification)
    notification.deliver_now
  end
end
