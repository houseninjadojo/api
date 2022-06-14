class Sync::PromoCode::Stripe::Inbound::CreatePolicy < ApplicationPolicy
  authorize :webhook_event
  authorize :user, optional: true

  def can_sync?
    webhook_is_unprocessed? &&
    has_external_id? &&
    is_new_record? &&
    has_coupon_id?
  end

  def has_external_id?
    record.data&.object&.id.present?
  end

  def is_new_record?
    !PromoCode.exists?(stripe_id: record.data&.object&.id)
  end

  def webhook_is_unprocessed?
    !webhook_event.processed?
  end

  def has_coupon_id?
    record.data&.object&.coupon&.id.present?
  end

  private

  def record
    if @record.is_a?(Stripe::Event)
      @record
    else
      Stripe::Event.construct_from(@record)
    end
  end
end
