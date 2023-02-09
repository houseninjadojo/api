class DocumentMailer < ApplicationMailer
  before_action {
    @document = params[:document]
  }

  after_action :prevent_delivery_unless_houseninja

  def receipt
    @template_id = 'd-817572d309d140029cd6837d3ea3670f'
    @subject = "Your receipt is ready"
    attachments["receipt.pdf"] = attachment
    mail(mail_params)
  end

  private

  def should_cancel_delivery?
    !@document.has_asset?
  end

  def attachment
    @document.asset.download
  end
end
