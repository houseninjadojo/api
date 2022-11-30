class Sync::Payment::Stripe::Inbound::UpdateJob < Sync::BaseJob
  attr_accessor :webhook_event

  def perform(webhook_event)
    @webhook_event = webhook_event

    return unless policy.can_sync?

    payment.update!(params)

    webhook_event.update!(processed_at: Time.now)

    attach_receipt_to_invoice
  end

  def policy
    Sync::Payment::Stripe::Inbound::UpdatePolicy.new(
      stripe_event,
      webhook_event: webhook_event
    )
  end

  def params
    {
      amount: stripe_object.amount,
      description: stripe_object.description,
      paid: stripe_object.paid,
      refunded: stripe_object.refunded,
      statement_descriptor: stripe_object.statement_descriptor,
      status: stripe_object.status,
      paid_at: (Time.at(stripe_object[:status_transitions]&[:paid_at]) if stripe_object[:status_transitions]&[:paid_at].present?),

      invoice: invoice,
      payment_method: payment_method,
      user: user,

      stripe_object: stripe_object,
    }.compact
  end

  def payment
    @payment ||= Payment.find_by(stripe_id: stripe_object.id) if stripe_object&.id.present?
  end

  def invoice
    @invoice ||= Invoice.find_by(stripe_id: stripe_object.invoice) if stripe_object&.invoice.present?
  end

  def user
    @user ||= User.find_by(stripe_id: stripe_object.customer) if stripe_object&.customer.present?
  end

  def payment_method
    @payment_method ||= PaymentMethod.find_by(stripe_token: stripe_object.payment_method) if stripe_object&.payment_method.present?
  end

  def stripe_event
    @resource ||= Stripe::Event.construct_from(webhook_event.payload)
  end

  def stripe_object
    stripe_event.data.object
  end

  def receipt_url
    return if stripe_object&.receipt_url.nil?
    @receipt_url ||= begin
      content = OpenURI.open_uri(stripe_object.receipt_url)&.read
      # receipt_uri = content.match(/(https\:\/\/pay\.stripe\.com\/invoice\/[\w\/\_]+\/pdf\?s\=em)/)
      receipt_uri = content.match(/(https\:\/\/dashboard\.stripe\.com\/(receipts\/invoices|emails\/receipts)\/[\w\_\-]+\/pdf)/)
      receipt_uri.present? ? receipt_uri[1] : nil
    rescue => e
      Rails.logger.warn(e)
      Sentry.capture_exception(e)
      nil
    end
  end

  def receipt_pdf
    return if receipt_url.nil?
    @receipt_pdf ||= begin
      file = OpenURI.open_uri(receipt_url)
      file if file&.content_type == "application/pdf"
    rescue => e
      Rails.logger.warn(e)
      Sentry.capture_exception(e)
      nil
    end
  end

  def attach_receipt_to_invoice
    return if invoice.nil? || receipt_pdf.nil?
    receipt = Document.find_or_create_by(invoice: invoice, user: user, tags: [Document::SystemTags::RECEIPT])
    receipt.asset.attach(io: receipt_pdf, filename: "receipt.pdf")
    receipt.save
  end
end
