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
    if !Rails.env.test?
      Rails.logger.info("sync policy action=update invoice=#{record.id}", {
        policy: {
          resource: "invoice",
          service: "stripe",
          direction: "outbound",
          action: "update",
          result: can_sync_result,
        },
        resource: {
          id: record&.id,
          type: "invoice",
        },
        factors: {
          has_external_id: has_external_id?,
          has_changed_attributes: has_changed_attributes?,
          is_modifiable: is_modifiable?,
        },
        changeset: changeset,
      })
    end
    can_sync_result
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

  private

  def can_sync_result
    has_external_id? &&
    has_changed_attributes? &&
    is_modifiable?
  end
end
