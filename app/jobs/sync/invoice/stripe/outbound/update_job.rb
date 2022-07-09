class Sync::Invoice::Stripe::Outbound::UpdateJob < Sync::BaseJob
  attr_accessor :resource, :changeset

  def perform(resource, changeset)
    @changeset = changeset
    @resource = resource
    return unless policy.can_sync?

    # if description_changed?
    updated_invoice = Stripe::Invoice.update(resource.stripe_id, params)
    # end

    # update invoice
    line_item_id = invoice.lines&.first&.id
    if line_item_id.present?
      updated_invoice = Stripe::InvoiceItem.update(line_item_id, line_item_params)
    end

    # if description_changed?
    #   Stripe::Invoice.update(resource.stripe_id, params)
    # end

    if work_order_status_changed?
      case resource.work_order&.status
      when WorkOrderStatus::INVOICE_SENT_TO_CUSTOMER
        Stripe::Invoice.finalize_invoice(resource.stripe_id, { auto_advance: false })
      end
    end
  end

  def params
    {
      description: resource.description,
    }
  end

  def line_item_params
    {
      amount: resource.total,
    }
  end

  def policy
    Sync::Invoice::Stripe::Outbound::UpdatePolicy.new(
      resource,
      changeset: changeset
    )
  end

  def work_order_status_changed?
    changeset.find { |change| change[:path] == [:work_order, :status] }.present?
  end

  def description_changed?
    paths = [
      [:work_order, :invoice_notes],
      [:description],
    ]
    changeset.find { |change| paths.include?(change[:path]) }.present?
  end

  def amount_changed?
    paths = [
      [:work_order, :homeowner_amount],
      [:work_order, :homeowner_amount_actual],
    ]
    changeset.find { |change| paths.include?(change[:path]) }.present?
  end

  def invoice
    invoice ||= Stripe::Invoice.retrieve(resource.stripe_id)
  end

  def idempotency_key
    Digest::SHA256.hexdigest("#{resource.id}#{resource.updated_at.to_i}")
  end
end
