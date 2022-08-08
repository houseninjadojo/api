class Invoice::NotifyJob < ApplicationJob
  queue_as :default
  unique :until_expired, lock_ttl: 5.minutes

  attr_accessor :invoice, :user, :device, :work_order

  def perform(invoice)
    @invoice = invoice
    @user = @invoice&.user
    @device = @user&.current_device
    @work_order = @invoice&.work_order

    return unless should_send?

    notification.deliver_later
  end

  def body
    "You have a new invoice ready for payment"
  end

  def deeplink_path
    "/work-orders/#{invoice.work_order.id}"
  end

  def notification
    @notification ||= PushNotification.create!(
      device: device,
      body: body,
      deeplink_path: deeplink_path,
    )
  end

  private

  def should_send?
    work_order.present? &&
    device.present? &&
    user.email.include?("@houseninja.co")
  end
end
