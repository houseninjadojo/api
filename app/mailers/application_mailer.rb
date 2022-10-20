class ApplicationMailer < ActionMailer::Base
  default from: default_from
  default bcc: Rails.secrets.dig(:hubspot, :log_email)

  layout "mailer"

  before_action :set_user_and_email,
                :set_app_store_url

  after_action :prevent_delivery_without_email,
               :prevent_delivery_without_template_id

  protected

  # callbacks

  def set_user_and_email
    @user = params[:user]
    @email = @user&.email
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

  def prevent_delivery_without_template_id
    if @template_id.blank?
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

  # helpers

  # def attach_hubspot_bcc
  #   mail_settings = {
  #     bcc: {
  #       enable: Rails.secrets.dig(:hubspot, :log_email).present?,
  #       email: Rails.secrets.dig(:hubspot, :log_email)
  #     }
  #   }
  #   mail(mail_settings: mail_settings)
  # end

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
end
