class ReceiptMailer < ApplicationMailer
  before_action {
    @document = params[:document]
  }

  def receipt
    @template_id = 'd-287df16bd5bb4153b442a9da7bd226b8'
    @subject = "Here is your receipt."
    # file name should have date or something?
    attachments['receipt.pdf'] = @document.asset.download
    mail(mail_params)
  end
end
