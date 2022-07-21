class Temp::FetchPaymentDocumentJob < ApplicationJob
  sidekiq_options retry: 0
  queue_as :default

  unique :until_executed

  def perform(payment)
    charge = payment.stripe_object
    attach_receipt(payment)
  end

  def receipt_url(charge)
    begin
      content = OpenURI.open_uri(charge["receipt_url"])&.read
      receipt_uri = content.match(/(https\:\/\/dashboard\.stripe\.com\/(receipts\/invoices|emails\/receipts)\/[\w\_\-]+\/pdf)/)
      receipt_uri.present? ? receipt_uri[1] : nil
    rescue => e
      puts "Error: #{e.message}"
      nil
    end
  end

  def receipt_pdf(payment)
    receipt_url = receipt_url(payment.stripe_object)
    begin
      file = OpenURI.open_uri(receipt_url)
      file if file&.content_type == "application/pdf"
    rescue => e
      puts "Error: #{e.message}"
      nil
    end
  end

  def document_params(payment)
    {
      tags: ['system:receipt'],
      payment_id: payment.id,
      user_id: payment.user_id,
      created_at: payment.created_at,
      updated_at: payment.updated_at,
    }
  end

  def find_or_upsert_document(payment)
    doc = Document.find_by(payment_id: payment.id)
    if doc.nil?
      params = document_params(payment)
      Document.upsert(params)
      Document.find_by(payment_id: payment.id)
    else
      doc
    end
  end

  def attach_receipt(payment)
    receipt_pdf = receipt_pdf(payment)
    return if receipt_pdf.nil?
    document = find_or_upsert_document(payment)
    return if document.asset.present?
    document.asset.attach(io: receipt_pdf, filename: "receipt.pdf")
  end
end
