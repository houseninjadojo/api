class UserMailer < ApplicationMailer
  def account_setup #(email:, url:)
    @template_id = 'd-fc9c5420ba1d4a96902f3292a31d7ae5'
    @email = params[:email]
    @url = params[:url]
    mail(
      to: @email,
      body: '',
      template_id: @template_id,
      dynamic_template_data: {
        url: @url,
      }
    )
  end

  def delete_request(user:)
    @template_id = 'd-fa5ae35cc727496fb2e01c69e4cd04a9'
    @email = "miles@houseninja.co"
    mail(
      to: @email,
      body: '',
      template_id: @template_id,
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
