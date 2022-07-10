class Sync::Invoice::Stripe::Outbound::UpdatePolicy < ApplicationPolicy
  class Changeset < TreeDiff
    observe :description,
            :total,
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
    Rails.logger.info("Invoice::Stripe::Outbound::UpdatePolicy.can_sync?")
    Rails.logger.info("  has_external_id?=#{has_external_id?}")
    Rails.logger.info("  has_changed_attributes?=#{has_changed_attributes?}")
    Rails.logger.info("  is_modifiable?=#{is_modifiable?}")
    Rails.logger.info("changeset: #{changeset.inspect}")
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
