class SystemMailer < ApplicationMailer
  default from: "api-alerts@houseninja.co"

  def privacy_delete_request
    @email = email_address_with_name("miles@houseninja.co", "Miles")
    @subject = 'CRITICAL - Hubspot Privacy Delete Requested'
    @body = "Payload for the request was: #{params[:payload].inspect}"
    @template_data = {
      payload: params[:payload],
    }
    mail(mail_params)
  end

  def test_request
    @email = 'miles@houseninja.co'
    mail(
      to: @email,
      from: @email,
      subject: 'Test Request Success',
      body: 'Request received and processed',
    )
  end
end
