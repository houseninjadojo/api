class ApplicationMailer < ActionMailer::Base
  default from: Rails.settings.email[:reply_to]
  layout "mailer"
end
