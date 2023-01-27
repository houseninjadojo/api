require "rails_helper"

RSpec.describe ReceiptMailer, type: :mailer do
  describe "mailing user receipt" do
    let(:user) { create(:user) }
    let(:document) {
      create(:document, user: user)
    }
    let(:mail) {
      ReceiptMailer.with(document).payment_approval
    }
    it "calls sendgrid" do
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["hello@houseninja.co"])
      expect(mail.body).to eq('')
      # expect(mail[:'template-id'].to_s).to eq('d-8f179d92b29645278a32855f82eda36b') ???
      expect(mail[:dynamic_template_data].value).to eq({
        subject: "Here is your receipt.",
        first_name: user.first_name,
        app_store_url: Rails.settings.app_store_url,
      }.to_s)
    end
  end
end
