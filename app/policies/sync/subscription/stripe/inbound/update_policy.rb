class Sync::Subscription::Stripe::Inbound::UpdatePolicy < ApplicationPolicy
  authorize :webhook_event
  authorize :user, optional: true

  def can_sync?
    webhook_is_unprocessed? &&
    has_external_id? &&
    !is_new_record? &&
    is_active?
  end

  def has_external_id?
    subscription[:id].present?
  end

  def is_new_record?
    !Subscription.exists?(stripe_id: subscription[:id])
  end

  def webhook_is_unprocessed?
    !webhook_event.processed?
  end

  def is_active?
    return false unless subscription[:id].present?
    Subscription.find_by(stripe_id: subscription[:id])&.active?
  end

  private

  def subscription
    record.data&.object
  end

  def record
    if @record.is_a?(Stripe::Event)
      @record
    else
      Stripe::Event.construct_from(@record)
    end
  end
end
