class EstimateMailer < ApplicationMailer
  default from: Rails.settings.email[:reply_to]

  def estimate_approval(
    email:,
    first_name:,
    service_name:,
    service_provider:,
    estimate_amount_or_actual_estimate_if_populated:,
    estimate_notes:,
    estimate_link:,
    app_store_url: Rails.settings.app_store_url
  )
    if email.ends_with?('@houseninja.co')
      mail(
        to: email,
        body: '',
        template_id: 'd-63a05b08f1ab43a3865811ef9509a2fc',
        dynamic_template_data: {
          subject: "You have an estimate ready for #{service_name}",
          first_name: first_name,
          service_name: service_name,
          service_provider: service_provider,
          estimate_amount_or_actual_estimate_if_populated: estimate_amount_or_actual_estimate_if_populated,
          estimate_notes: estimate_notes,
          estimate_link: estimate_link,
          app_store_url: app_store_url
        }
      )
    else
      nil
    end
  end
end
