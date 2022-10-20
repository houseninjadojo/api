class ApplicationMailer < ActionMailer::Base
  self.deliver_later_queue_name = :mailers

  layout "mailer"

  before_action :set_user_and_email,
                :set_app_store_url

  after_action :prevent_delivery_without_email,
               :cancel_delivery_before_submit


  default from: -> { default_from },
          bcc:  -> { Rails.secrets.dig(:hubspot, :log_email) },
          to:   -> { @email }

  protected

  # callbacks

  def set_user_and_email
    @user = params[:user]
    @email = email_address_with_name(@user&.email, @user&.full_name)
    @first_name = @user&.first_name
  end

  def set_app_store_url
    @app_store_url = params[:app_store_url] || Rails.settings.app_store_url
  end

  def prevent_delivery_without_email
    if @email.blank?
      Rails.logger.error("not delivering email - template_id is blank", log_tags)
      mail.perform_deliveries = false
    end
  end

  def prevent_delivery_unless_houseninja
    if !@email&.ends_with?('@houseninja.co')
      Rails.logger.error("not delivering email - not a houseninja email address", log_tags)
      mail.perform_deliveries = false
    end
  end

  def cancel_delivery_before_submit
    if should_cancel_delivery?
      Rails.logger.info("#{self.class.name} - Canceling delivery", log_tags)
      mail.perform_deliveries = false
    end
  end

  # OVERLOAD THIS
  def should_cancel_delivery?
    false
  end

  def params
    super || {}
  end

  # helpers

  def default_from
    email_address_with_name(
      Rails.settings.email[:reply_to],
      Rails.settings.email[:name]
    )
  end

  def log_tags
    {
      sendgrid: {
        template: { id: @template_id },
      },
      usr: {
        email: @email,
      }
    }
  end

  # sendgrid params

  def subject
    params[:subject] || @subject
  end

  def base_params
    {
      to: @email,
      body: @body || '',
      template_id: @template_id,
    }
  end

  def default_template_data
    {
      subject: subject,
      first_name: @first_name,
      app_store_url: @app_store_url,
    }.compact
  end

  def mail_settings
    {
      bcc: {
        enable: Rails.secrets.dig(:hubspot, :log_email).present?,
        email: Rails.secrets.dig(:hubspot, :log_email)
      }
    }
  end

  def dynamic_template_data
    if @template_id.present?
      {
        **default_template_data,
        **(@template_data || {}),
      }
    else
      nil
    end
  end

  def mail_params
    params = {
      **base_params,
      mail_settings: mail_settings,
      dynamic_template_data: dynamic_template_data
    }.compact
  end
end
