require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "account_setup" do
    let(:mail) {
      UserMailer.account_setup(
        email: "test@houseninja.co",
        url: "https://www.houseninja.co"
      )
    }

    it "calls sendgrid" do
      expect(mail.to).to eq(["test@houseninja.co"])
      expect(mail.from).to eq(["hello@houseninja.co"])
      expect(mail.body).to eq('')
      expect(mail[:'template-id'].to_s).to eq('d-fc9c5420ba1d4a96902f3292a31d7ae5')
      expect(mail[:dynamic_template_data].value).to eq({
        url: "https://www.houseninja.co"
      }.to_s)
    end
  end
end
