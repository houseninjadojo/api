class Invoice::NotifyJob < ApplicationJob
  queue_as :default
  unique :until_expired, lock_ttl: 5.minutes

  attr_accessor :invoice, :user, :device, :work_order

  def perform(invoice)
    @invoice = invoice
    @user = @invoice&.user
    @device = @user&.current_device
    @work_order = @invoice&.work_order

    if should_send?
      notification.deliver_later
    else
      Rails.logger.info("Not sending PushNotification for invoice=#{invoice.id}",
        invoice: invoice.id,
        user: user&.id,
        device: device&.id,
        work_order: work_order&.id,
      )
      clear_lock!
    end
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
    user.present? &&
    user.email.include?("@houseninja.co")
  end

  def clear_lock!
    Invoice::NotifyJob.unlock!(invoice)
  end
end
