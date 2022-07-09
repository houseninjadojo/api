class Sync::Invoice::Stripe::Outbound::UpdatePolicy < ApplicationPolicy
  class Changeset < TreeDiff
    observe :description,
            work_order: [
              :status,
              :homeowner_amount,
              :homeowner_amount_actual,
              :refund_amount,
              :invoice_notes,
            ]
  end

  authorize :user, optional: true
  authorize :changeset

  def can_sync?
    has_external_id? &&
    has_changed_attributes? &&
    is_modifiable?
  end

  def has_external_id?
    record&.stripe_id.present?
  end

  def has_changed_attributes?
    !changeset.blank?
  end

  def is_modifiable?
    record&.draft?
  end

  def is_actionable?
    [
      WorkOrderStatus::INVOICE_SENT_TO_CUSTOMER,
      WorkOrderStatus::INVOICE_PAID_BY_CUSTOMER,
    ].include?(record&.work_order&.status)
  end
end
