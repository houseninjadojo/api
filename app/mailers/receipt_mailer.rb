class ReceiptMailer < ApplicationMailer
  before_action {
    @document = params[:document]
  }

  def receipt
    @template_id = 'd-817572d309d140029cd6837d3ea3670f'
    @subject = "Here is your receipt."
    attachments["receipt-#{@document.id}.pdf"] = @document.asset.download
    mail(mail_params)
  end
end
