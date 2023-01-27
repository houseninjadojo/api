class ReceiptMailer < ApplicationMailer
  def receipt
    @document = params[:document]
    # file name should have date or something?
    attachments['receipt.pdf'] = File.read(@document.asset.path)
    mail(to: @document.user.email, subject: "Your Receipt")
  end
end
