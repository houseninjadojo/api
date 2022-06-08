class Sync::Invoice::Stripe::Outbound::UpdatePolicy < ApplicationPolicy
  authorize :user, optional: true
  authorize :changed_attributes

  def can_sync?
    should_sync? &&
    has_external_id? &&
    (has_changed_attributes? || is_actionable?)
  end

  def should_sync?
    record.should_sync?
  end

  def has_external_id?
    record&.stripe_id.present?
  end

  def has_changed_attributes?
    (changed_attributes.keys & attributes).any?
  end

  def has_changed_associations?
  end

  def is_actionable?
    record&.work_order&.status == WorkOrderStatus::INVOICE_SENT_TO_CUSTOMER ||
    record&.work_order&.status == WorkOrderStatus::INVOICE_PAID_BY_CUSTOMER
  end

  private

  def attributes
    [
      'description',
    ]
  end
end
