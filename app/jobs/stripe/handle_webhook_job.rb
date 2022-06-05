class Stripe::HandleWebhookJob < ApplicationJob
  sidekiq_options retry: 0
  queue_as :default

  def perform(webhook_event)
    return if webhook_event.processed_at.present?
    return unless enabled?
    @payload = webhook_event.payload

    case
    when event == "customer.updated"
      ActiveRecord::Base.transaction do
        user = User.find_by(stripe_customer_id: stripe_id) if stripe_id.present?
        return if user.nil?
        user.update!(user_attributes)
        webhook_event.update(processed_at: Time.now)
      end
    when event == "customer.created"
      ActiveRecord::Base.transaction do
        user = User.find_by(stripe_customer_id: stripe_id) if stripe_id.present?
        if user.present?
          webhook_event.update(processed_at: Time.now)
          return
        end
        user = User.new(user_attributes)
        user.stripe_customer_id = stripe_id
        # @todo
        # enable this when ready
        # user.save!
        # webhook_event.update(processed_at: Time.now)
      end
    # `invoice.*` except `invoice.deleted`
    when !!event.match(/^invoice\.(?!deleted).*$/)
      ActiveRecord::Base.transaction do
        user = User.find_by(stripe_customer_id: object["customer"]) if object["customer"].present?
        subscription = Subscription.find_by(stripe_subscription_id: object["subscription"]) if object["subscription"].present?
        payment = Payment.find_by(stripe_id: object["charge"]) if object["charge"].present?
        invoice = Invoice.find_or_create_by(stripe_id: stripe_id) if stripe_id.present?
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
      end
    # `charge.*` except `charge.dispute.*` or `charge.refund.*`
    when !!event.match(/^charge\.[a-z]+(?![.a-z]).*$/)
      Payment.from_stripe_charge!(object)
    # `customer.subscription.*`
    when !!event.match(/^customer\.subscription\.[a-z_]+$/)
      ActiveRecord::Base.transaction do
        subscription = Subscription.find_by(stripe_subscription_id: stripe_id) if stripe_id.present?
        if subscription.present?
          subscription.update(stripe_object: @payload)
        else
          nil
        end
      end
    # `payment_method.attached`
    when !!event.match(/^payment_method\.attached$/)
      ActiveRecord::Base.transaction do
        user = User.find_by(stripe_customer_id: object["customer"]) if object["customer"].present?
        payment_method = PaymentMethod.find_by(stripe_id: stripe_id) if stripe_id.present?
        if payment_method.present?
          payment_method.update(
            brand: object["card"]["brand"],
            last_four: object["card"]["last4"],
            stripe_object: @payload
          )
        else
          nil
        end
      end
    # `promotion_code.*`
    when !!event.match(/^promotion_code\.[a-z]+(?![.a-z]).*$/)
      ActiveRecord::Base.transaction do
        promo_code = PromoCode.find_or_create_by(
          stripe_id: stripe_id,
          code: object["code"],
        )
        promo_code.update(
          active: object["active"],
          amount_off: object.dig("coupon", "amount_off"),
          coupon_id: object.dig("coupon", "id"),
          name: object.dig("coupon", "name"),
          percent_off: object.dig("coupon", "percent_off"),
          stripe_object: @payload
        )
      end
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

  def enabled?
    ENV["STRIPE_WEBHOOK_DISABLED"] != "true"
  end
end
