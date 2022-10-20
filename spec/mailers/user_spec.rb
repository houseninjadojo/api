require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "account_setup" do
    let(:user) { create(:user, onboarding_link: 'https://www.houseninja.co') }
    let(:mail) {
      UserMailer.with(user: user).account_setup
    }

    it "calls sendgrid" do
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["hello@houseninja.co"])
      expect(mail.body).to eq('')
      expect(mail[:'template-id'].to_s).to eq('d-fc9c5420ba1d4a96902f3292a31d7ae5')
      expect(mail[:dynamic_template_data].value).to eq({
        first_name: user.first_name,
        app_store_url: Rails.settings.app_store_url,
        url: "https://www.houseninja.co",
      }.to_s)
    end
  end
end
