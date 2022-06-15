class Sync::Invoice::Stripe::Inbound::CreatePolicy < ApplicationPolicy
  authorize :webhook_event
  authorize :user, optional: true

  def can_sync?
    webhook_is_unprocessed? &&
    has_external_id? &&
    is_new_record? &&
    has_user_id?
  end

  def has_external_id?
    invoice&.id.present?
  end

  def is_new_record?
    !Invoice.exists?(stripe_id: invoice&.id)
  end

  def webhook_is_unprocessed?
    !webhook_event.processed?
  end

  def has_user_id?
    invoice&.customer.present?
  end

  private

  def invoice
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
