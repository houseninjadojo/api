class Sync::Invoice::Stripe::Outbound::CreateJob < Sync::BaseJob
  attr_accessor :resource

  def perform(resource)
    @resource = resource
    return unless policy.can_sync?

    # we have to create invoice line_items on Stripe side first
    line_item = Stripe::InvoiceItem.create(line_item_params)

    # create the invoice
    begin
      invoice = Stripe::Invoice.create(params, { idempotency_key: idempotency_key })
    rescue Stripe::InvalidRequestError => e
      # if the payment method is invalid, try again without it
      if e.message.include?('payment method')
        Rails.logger.warn("failed when trying to create invoice=#{resource.id}. trying without payment method - #{e.message}")
        idempotency_key = Digest::SHA256.hexdigest("#{resource.id}#{resource.updated_at.to_i + 1}")
        invoice = Stripe::Invoice.create(params.except(:default_payment_method), { idempotency_key: idempotency_key })
      else
        raise e
      end
    end

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
