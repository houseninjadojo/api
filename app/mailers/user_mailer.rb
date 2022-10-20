class UserMailer < ApplicationMailer
  def account_setup
    @template_id = 'd-fc9c5420ba1d4a96902f3292a31d7ae5'
    @template_data = {
      url: @user&.onboarding_link,
    }
    mail(mail_params)
  end

  def delete_request
    @template_id = 'd-fa5ae35cc727496fb2e01c69e4cd04a9'
    @email = email_address_with_name("miles@houseninja.co", "Miles")
    @template_data = {
      email: @user&.email,
      name: @user&.full_name,
      requested_at: Time.zone.now.to_s(:long),
    }
    mail({
      **mail_params,
      **personalizations
    })
  end

  private

  def personalizations
    {
      personalizations: [
        {
          to: [
            { email: "miles@houseninja.co" },
            { email: "rachael@houseninja.co" },
            { email: "hello@houseninja.co" },
          ],
        },
      ]
    }
  end
end
