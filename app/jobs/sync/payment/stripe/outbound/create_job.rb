class Sync::Payment::Stripe::Outbound::CreateJob < ApplicationJob
  queue_as :default

  attr_accessor :resource

  def perform(resource)
    @resource = resource
    return unless policy.can_sync?

    # We are hijacking this action to instead create a
    # payment through paying a stripe invoice
    pay_invoice!
  end

  # def params
  #   {
  #     coupon: resource.coupon_id,
  #     code: resource.code,
  #   }
  # end

  def policy
    Sync::Payment::Stripe::Outbound::CreatePolicy.new(
      resource
    )
  end

  def pay_invoice!
    invoice = resource.invoice
    user = resource.property&.user
    return if invoice.nil?

    invoice.update!(payment_attempted_at: Time.current)

    begin
      paid_invoice = Stripe::Invoice.pay(invoice.stripe_id, {
        payment_method: user.default_payment_method&.stripe_token,
      })
      update!(
        status: paid_invoice.status,
        stripe_object: paid_invoice
      )
      if paid_invoice.status == "payment_failed"
        work_order.update!(status: WorkOrderStatus::PAYMENT_FAILED)
        return nil
      else
        work_order.update!(status: WorkOrderStatus::INVOICE_PAID_BY_CUSTOMER)
        # refresh_pdf!
        return paid_invoice
      end
    rescue => e
      Rails.logger.error "Stripe::Invoice.pay(#{stripe_id}) failed: #{e.message}"
      Sentry.capture_exception(e)
      return nil
    end
  end
end
