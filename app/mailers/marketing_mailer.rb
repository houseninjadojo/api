class MarketingMailer < ApplicationMailer
  def app_announcement
    @template_id = 'd-32e6334f2ec24e968189c9ad6aa8f7fa'
    @email = params[:email]
    @url = params[:url] || Rails.settings.app_store_url
    mail(
      to: @email,
      body: '',
      template_id: @template_id,
      dynamic_template_data: {
        url: @url,
      }
    )
  end
end
