class InvoiceMailer < ApplicationMailer
  default from: Rails.settings.email[:reply_to]

  def payment_approval(
    email:,
    first_name:,
    service_name:,
    service_provider:,
    invoice_amount:,
    invoice_notes:,
    payment_link:,
    app_store_url: Rails.settings.app_store_url
  )
    mail(
      to: email,
      body: '',
      template_id: 'd-8f179d92b29645278a32855f82eda36b',
      dynamic_template_data: {
        first_name: first_name,
        service_name: service_name,
        service_provider: service_provider,
        invoice_amount: invoice_amount,
        invoice_notes: invoice_notes,
        payment_link: payment_link,
        app_store_url: app_store_url
      }
    )
  end
end
