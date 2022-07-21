class MarketingMailer < ApplicationMailer
  default from: Rails.settings.email[:reply_to]

  def app_announcement(email:, url: Rails.settings.app_store_url)
    return unless email.include?("@houseninja.co")
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
