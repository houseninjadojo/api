require "rails_helper"

RSpec.describe MarketingMailer, type: :mailer do
  describe "payment_approval" do
    let(:mail) {
      MarketingMailer.app_announcement(
        email: "test@houseninja.co",
        url: "https://www.houseninja.co"
      )
    }

    it "calls sendgrid" do
      expect(mail.to).to eq(["test@houseninja.co"])
      expect(mail.from).to eq(["hello@houseninja.co"])
      expect(mail.body).to eq('')
      expect(mail[:'template-id'].to_s).to eq('d-32e6334f2ec24e968189c9ad6aa8f7fa')
      expect(mail[:dynamic_template_data].value).to eq({
        url: "https://www.houseninja.co"
      }.to_s)
    end
  end
end
