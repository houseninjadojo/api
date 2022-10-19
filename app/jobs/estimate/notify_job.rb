class Estimate::NotifyJob < ApplicationJob
  queue_as :default
  unique :until_expired, lock_ttl: 10.seconds

  attr_accessor :estimate, :user, :device, :work_order

  def perform(estimate)
    @estimate = estimate
    @user = @estimate.work_order&.user
    @device = @user&.current_device
    @work_order = @estimate&.work_order

    if should_send?
      notification.deliver_later
    else
      Rails.logger.info("Not sending PushNotification for estimate=#{estimate.id}",
        estimate: estimate.id,
        user: user&.id,
        device: device&.id,
        work_order: work_order&.id,
      )
      clear_lock!
    end
  end

  def body
    "You have a new estimate ready for review"
  end

  def deeplink_path
    "/work-orders/#{estimate.work_order.id}"
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
    estimate.present? &&
    work_order.present? &&
    device.present? &&
    user.present? &&
    user.is_houseninja?
  end

  def clear_lock!
    Estimate::NotifyJob.unlock!(estimate)
  end
end
