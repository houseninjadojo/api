class EstimateMailer < ApplicationMailer
  before_action {
    @estimate = params[:estimate]
    @work_order = @estimate&.work_order
  }

  after_action :prevent_delivery_unless_houseninja

  def estimate_approval
    @template_id = 'd-63a05b08f1ab43a3865811ef9509a2fc'
    @subject = "You have an estimate ready for #{@work_order.description}"
    @template_data = {
      service_name: @work_order.description,
      service_provider: @work_order.vendor,
      estimate_amount_or_actual_estimate_if_populated: @estimate.formatted_total,
      estimate_notes:  @estimate.description&.to_s&.gsub(/\n/, '<br>')&.html_safe,
      estimate_link: @estimate.deep_link&.to_s,
    }
    mail(mail_params)
  end

  private

  def should_cancel_delivery?
    !@estimate.should_share_with_customer?
  end
end
