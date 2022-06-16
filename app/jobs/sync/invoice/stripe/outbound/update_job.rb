class Sync::Invoice::Stripe::Outbound::UpdateJob < Sync::BaseJob
  attr_accessor :resource, :changeset

  def perform(resource, changeset)
    @changeset = changeset
    @resource = resource
    return unless policy.can_sync?

    # update invoice
    if description_changed?
      Stripe::Invoice.update(resource.stripe_id, params)
    end

    if work_order_status_changed?
      case resource.work_order&.status
      when WorkOrderStatus::INVOICE_SENT_TO_CUSTOMER
        Stripe::Invoice.finalize_invoice(resource.stripe_id, { auto_advance: false })
      # when WorkOrderStatus::INVOICE_PAID_BY_CUSTOMER
        # Stripe::Invoice.pay(resource.stripe_id, {
        #   payment_method: resource.user&.default_payment_method&.stripe_token,
        # })
      end
    end
  end

  def params
    {
      description: resource.description,
    }
  end

  def policy
    Sync::Invoice::Stripe::Outbound::UpdatePolicy.new(
      resource,
      changeset: changeset
    )
  end

  def work_order_status_changed?
    changeset.find { |change| change.path == [:work_order, :status] }.present?
  end

  def description_changed?
    changeset.find { |change| change.path == [:description] }.present?
  end

  def idempotency_key
    Digest::SHA256.hexdigest("#{resource.id}#{resource.updated_at.to_i}")
  end
end
