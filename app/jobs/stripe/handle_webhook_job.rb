class Stripe::HandleWebhookJob < ApplicationJob
  sidekiq_options retry: 0
  queue_as :default

  def perform(webhook_job)
    return if webhook_job.processed_at.present?
    @payload = webhook_job.payload

    case
    when event == "customer.updated"
      user = User.find_by(stripe_customer_id: stripe_id)
      return if user.nil?
      user.update_from_service("stripe", user_attributes)
      webhook_job.update(processed_at: Time.now)
    when event == "customer.created"
      user = User.find_by(stripe_customer_id: stripe_id)
      if user.present?
        webhook_job.update(processed_at: Time.now)
        return
      end
      user = User.new(user_attributes)
      user.stripe_customer_id = stripe_id
      # @todo
      # enable this when ready
      # user.save!
      # webhook_job.update(processed_at: Time.now)

    # `invoice.*` except `invoice.deleted`
    when !!event.match(/^invoice\.(?!deleted).*$/)
      user = User.find_by(stripe_customer_id: object["customer"])
      subscription = Subscription.find_by(stripe_subscription_id: object["subscription"])
      payment = Payment.find_by(stripe_id: object["charge"])
      invoice = Invoice.find_or_create_by(stripe_id: stripe_id)
      invoice.update(
        description: object["description"],
        payment: payment,
        period_end: Time.at(object["period_end"]),
        period_start: Time.at(object["period_start"]),
        status: object["status"],
        stripe_object: @payload,
        subscription: subscription,
        total: object["total"],
        user: user
      )
      if invoice.document.nil? && object["invoice_pdf"].present?
        asset = URI.open(object["invoice_pdf"])
        document = Document.create(
          invoice: invoice,
          user: user
        )
        document.asset.attach(io: asset, filename: "invoice.pdf")
      end
    # `charge.*` except `charge.dispute.*` or `charge.refund.*`
    when !!event.match(/^charge\.[a-z]+(?![.a-z]).*$/)
      invoice = Invoice.find_by(stripe_id: object["invoice"])
      payment_method = PaymentMethod.find_by(stripe_token: object["payment_method"])
      user = User.find_by(stripe_customer_id: object["customer"])
      payment = Payment.find_or_create_by(stripe_id: stripe_id)
      payment.update(
        amount: object["amount"],
        description: object["description"],
        invoice: invoice,
        paid: object["paid"],
        payment_method: payment_method,
        refunded: object["refunded"],
        statement_descriptor: object["statement_descriptor"],
        status: object["status"],
        stripe_object: @payload,
        user: user
      )
    # `customer.subscription.*`
    when !!event.match(/^customer\.subscription\.[a-z_]+$/)
      subscription = Subscription.find_by(stripe_subscription_id: stripe_id)
      if subscription.present?
        subscription.update(stripe_object: @payload)
      else
        nil
      end
    # `promotion_code.*`
    when !!event.match(/^promotion_code\.[a-z]+(?![.a-z]).*$/)
      promo_code = PromoCode.find_or_create_by(stripe_id: stripe_id)
      promo_code.update(
        active: object["active"],
        amount_off: object.dig("coupon", "amount_off"),
        code: object["code"],
        coupon_id: object.dig("coupon", "id"),
        name: object.dig("coupon", "name"),
        percent_off: object.dig("coupon", "percent_off"),
        stripe_object: @payload
      )
    end
  end

  def event
    @payload["type"]
  end

  def object
    @payload["data"]["object"]
  end

  def stripe_id
    object["id"]
  end

  def user_attributes
    first_name, last_name = split_name
    {
      email:        object["email"],
      phone_number: object["phone"],
      first_name:   first_name,
      last_name:    last_name,
    }
  end

  def split_name
    return [] if object["name"].blank?
    object["name"].split(" ")
  end
end
