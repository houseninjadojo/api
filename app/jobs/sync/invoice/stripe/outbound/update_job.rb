class Sync::Invoice::Stripe::Outbound::UpdateJob < ApplicationJob
  queue_as :default

  attr_accessor :resource, :changeset

  def perform(resource, changeset)
    @changeset = changeset
    @resource = resource
    return unless policy.can_sync?

    # Stripe::Invoice.update(property.user.stripe_id, params)

    # Finalize?
    # try_finalizing!

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

  # def try_finalizing!
  #   change = changeset.select{ |c| c.path == [:work_order, :status] }
  #   if change.present? && change[:new] == WorkOrderStatus::INVOICE_SENT_TO_CUSTOMER
  #     Stripe::Invoice.finalize_invoice(invoice.stripe_id, { auto_advance: false })
  #   end
  # end

  # def try_paying!
  # end
end
