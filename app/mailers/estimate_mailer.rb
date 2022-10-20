class EstimateMailer < ApplicationMailer
  before_action {
    @estimate = params[:estimate]
    @work_order = @estimate&.work_order
  }
  after_action :prevent_delivery_unless_houseninja

  def estimate_approval
    @template_id = 'd-63a05b08f1ab43a3865811ef9509a2fc'
    @service_name = @work_order.description
    @service_provider = @work_order.vendor
    @estimate_amount = @estimate.formatted_total
    @estimate_notes = @estimate.description&.to_s&.gsub(/\n/, '<br>')&.html_safe
    @estimate_link = @estimate.deep_link&.to_s
    @subject = "You have an estimate ready for #{@service_name}"
    mail(
        to: @email,
        body: '',
        template_id: @template_id,
        dynamic_template_data: {
          subject: @subject,
          first_name: @first_name,
          service_name: @service_name,
          service_provider: @service_provider,
          estimate_amount_or_actual_estimate_if_populated: @estimate_amount,
          estimate_notes: @estimate_notes,
          estimate_link: @estimate_link,
          app_store_url: @app_store_url
        },
        mail_settings: {
          bcc: {
            enable: Rails.secrets.dig(:hubspot, :log_email).present?,
            email: Rails.secrets.dig(:hubspot, :log_email)
          }
        }
      )
  end
end
