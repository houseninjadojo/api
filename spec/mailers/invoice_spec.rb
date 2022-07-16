require "rails_helper"

RSpec.describe InvoiceMailer, type: :mailer do
  describe "payment_approval" do
    let(:mail) {
      InvoiceMailer.payment_approval(
        email: "test@houseninja.co",
        first_name: "Test",
        invoice_amount: "$100.00",
        invoice_notes: "test\nnotest"&.to_s&.gsub(/\n/, '<br>')&.html_safe,
        service_name: "Test Service",
        service_provider: "Test Provider",
        payment_link: "https://app.houseninja.co/payment-link",
        app_store_url: "https://itunes.apple.com/us/app/houseninja/123456789"
      )
    }
    # let(:mail) { InvoiceMailer.payment_approval }

    it "calls sendgrid" do
      expect(mail.to).to eq(["test@houseninja.co"])
      expect(mail.from).to eq(["hello@houseninja.co"])
      expect(mail.body).to eq('')
      expect(mail[:'template-id'].to_s).to eq('d-8f179d92b29645278a32855f82eda36b')
      expect(mail[:dynamic_template_data].value).to eq({
        subject: "You have an invoice ready for payment for Test Service",
        first_name: "Test",
        service_name: "Test Service",
        service_provider: "Test Provider",
        invoice_amount: "$100.00",
        invoice_notes: "test<br>notest",
        payment_link: "https://app.houseninja.co/payment-link",
        app_store_url: "https://itunes.apple.com/us/app/houseninja/123456789"
      }.to_s)
    end
  end
end
