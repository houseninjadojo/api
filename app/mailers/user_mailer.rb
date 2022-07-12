class UserMailer < ApplicationMailer
  default from: Rails.settings.email[:reply_to]

  def account_setup(email:, url:)
    mail(
      to: email,
      body: '',
      template_id: 'd-fc9c5420ba1d4a96902f3292a31d7ae5',
      dynamic_template_data: {
        url: url,
      }
    )
  end

  def delete_request(user:)
    mail(
      to: "miles@houseninja.co",
      subject: "Delete Request for #{user.email}",
      body: 'Testing'
    )
  end
end
