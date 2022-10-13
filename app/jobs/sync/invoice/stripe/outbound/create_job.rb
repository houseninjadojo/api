class Sync::Invoice::Stripe::Outbound::CreateJob < Sync::BaseJob
  attr_accessor :resource

  def perform(resource)
    @resource = resource
    return unless policy.can_sync?

    # we have to create invoice line_items on Stripe side first
    line_item = Stripe::InvoiceItem.create(line_item_params)

    # create the invoice
    invoice = Stripe::Invoice.create(params, { idempotency_key: idempotency_key })

    # save to db
    resource.update!(
      status: invoice.status,
      stripe_id: invoice.id,
      stripe_object: invoice.as_json
    )
  end

  def params
    {
      auto_advance:           false,
      collection_method:      "charge_automatically",
      customer:               resource.user.stripe_id,
      default_payment_method: resource.user&.default_payment_method&.stripe_id,
      description:            description,
      subscription:           resource.subscription&.stripe_id,
      metadata:               {
        house_ninja_id: resource.id,
      },
    }
  end

  def line_item_params
    {
      amount:   resource.total || 0,
      currency: 'usd',
      customer: resource.user.stripe_id,
    }
  end

  def policy
    Sync::Invoice::Stripe::Outbound::CreatePolicy.new(
      resource
    )
  end

  def idempotency_key
    Digest::SHA256.hexdigest("#{resource.id}#{resource.updated_at.to_i}")
  end

  def description
    resource.description&.truncate(500)
  end
end
