class InvoiceMailer < ApplicationMailer
  before_action {
    @invoice = params[:invoice]
    @work_order = @invoice&.work_order || WorkOrder.new
  }

  def payment_approval
    @template_id = 'd-8f179d92b29645278a32855f82eda36b'
    @subject = "You have an invoice ready for payment for #{@work_order.description}"
    @template_data = {
      service_name: @work_order.description,
      service_provider: @work_order.vendor,
      invoice_amount: @invoice.formatted_total,
      invoice_notes: @invoice.notes&.to_s&.gsub(/\n/, '<br>')&.html_safe,
      payment_link: deep_link&.to_s,
      approve_invoice_header: approve_invoice_header,
    }
    mail(mail_params)
  end

  private

  def approve_invoice_header
    params[:approve_invoice_header] || "You have an invoice ready for payment."
  end

  def deep_link
    @invoice.deep_link || DeepLink.find_by(linkable: @invoice)
  end

  def should_cancel_delivery?
    return true unless @work_order.persisted?
    !@invoice.open? ||
    @work_order.status != WorkOrderStatus::INVOICE_SENT_TO_CUSTOMER ||
    @work_order&.customer_approved_work == false
  end
end
