class MarketingMailer < ApplicationMailer
  def app_announcement
    @template_id = 'd-32e6334f2ec24e968189c9ad6aa8f7fa'
    @email = params[:email]
    mail(mail_params)
  end
end
