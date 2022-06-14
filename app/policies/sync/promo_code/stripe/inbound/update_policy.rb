class Sync::PromoCode::Stripe::Inbound::UpdatePolicy < ApplicationPolicy
  authorize :webhook_event
  authorize :user, optional: true

  def can_sync?
    webhook_is_unprocessed? &&
    has_external_id? &&
    resource_exists?
  end

  def has_external_id?
    record.data&.object&.id.present?
  end

  def resource_exists?
    PromoCode.exists?(stripe_id: record.data&.object&.id)
  end

  def webhook_is_unprocessed?
    !webhook_event.processed?
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
