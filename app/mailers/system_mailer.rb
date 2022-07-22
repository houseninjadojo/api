class SystemMailer < ApplicationMailer
 default from: "api-alerts@houseninja.co"

  def privacy_delete_request(payload: {})
    mail(
      to: "miles@houseninja.co",
      subject: 'CRITICAL - Hubspot Privacy Delete Requested',
      body: "Payload for the request was: #{payload.inspect}",
      dynamic_template_data: {
        payload: payload,
      }
    )
  end
end
