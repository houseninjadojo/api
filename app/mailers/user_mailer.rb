class UserMailer < ApplicationMailer
  default from: Rails.settings.email[:reply_to]

  def account_setup
    @email = params[:email]
    @url = params[:url]
    mail(
      to: @email,
      body: '',
      template_id: 'd-fc9c5420ba1d4a96902f3292a31d7ae5',
      dynamic_template_data: {
        url: @url,
      }
    )
  end
end
