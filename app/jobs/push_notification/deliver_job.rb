class PushNotification::DeliverJob < ApplicationJob
  queue_as :default

  def perform(notification)
    notification.deliver_now
  end
end
