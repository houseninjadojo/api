class ReceiptMailer < ApplicationMailer
  def receipt
    @template_id = 'd-287df16bd5bb4153b442a9da7bd226b8'
    @document = params[:document]
    @subject = "Here is your receipt."
    # file name should have date or something?
    attachments['receipt.pdf'] = File.read(@document.asset.path)
    mail(to: @document.user.email, subject: "Your Receipt")
  end
end
