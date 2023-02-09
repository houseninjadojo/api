require "rails_helper"

RSpec.describe DocumentMailer, type: :mailer do
  describe "receipt" do
    let(:user) { create(:user) }
    let(:document) {
      create(:document, user: user)
    }
    let(:mail) {
      DocumentMailer.with(user: user, document: document).receipt
    }
    it "calls sendgrid" do
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["hello@houseninja.co"])
      expect(mail.body).to eq('')
      expect(mail[:'template-id'].to_s).to eq('d-817572d309d140029cd6837d3ea3670f')
      expect(mail[:dynamic_template_data].value).to eq({
        subject: "Your receipt is ready",
        first_name: user.first_name,
        app_store_url: Rails.settings.app_store_url,
      }.to_s)
      expect(mail.attachments.count).to eq 1
      expect(mail.attachments.first.filename).to eq "receipt.pdf"
    end
  end
end
