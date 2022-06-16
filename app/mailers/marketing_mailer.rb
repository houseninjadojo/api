class MarketingMailer < ApplicationMailer
  default from: Rails.settings.email[:reply_to]

  def app_announcement(email:, url:)
    mail(
      to: email,
      body: '',
      template_id: 'd-32e6334f2ec24e968189c9ad6aa8f7fa',
      dynamic_template_data: {
        url: url,
      }
    )
  end
end
