class UserMailer < ApplicationMailer
  default from: Rails.settings.email[:reply_to]

  def account_setup(email:, url:)
    return unless email.include?("@houseninja.co")
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
    return unless email.include?("@houseninja.co")
    mail(
      to: "miles@houseninja.co",
      body: '',
      template_id: 'd-fa5ae35cc727496fb2e01c69e4cd04a9',
      dynamic_template_data: {
        email: user&.email,
        name: user&.full_name,
        requested_at: Time.zone.now.to_s(:long),
      },
      personalizations: [
        {
          to: [
            { email: "miles@houseninja.co" },
            { email: "rachael@houseninja.co" },
            { email: "hello@houseninja.co" },
          ],
        },
      ]
    )
  end
end
