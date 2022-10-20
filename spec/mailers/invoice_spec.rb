require "rails_helper"

RSpec.describe InvoiceMailer, type: :mailer do
  describe "payment_approval" do
    let(:user) { create(:user) }
    let(:work_order) {
      create(:work_order,
        invoice_notes: "invoice\nnotes",
      )
    }
    let(:deep_link) {
      create(:deep_link, url: "https://app.houseninja.co/payment-link")
    }
    let(:invoice) {
      create(:invoice,
        deep_link: deep_link,
        work_order: work_order,
        status: 'open'
      )
    }
    let(:mail) {
      InvoiceMailer.with(user: user, invoice: invoice).payment_approval
    }
    # let(:mail) { InvoiceMailer.payment_approval }

    it "calls sendgrid" do
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["hello@houseninja.co"])
      expect(mail.body).to eq('')
      expect(mail[:'template-id'].to_s).to eq('d-8f179d92b29645278a32855f82eda36b')
      expect(mail[:dynamic_template_data].value).to eq({
        subject: "You have an invoice ready for payment for #{work_order.description}",
        first_name: user.first_name,
        app_store_url: Rails.settings.app_store_url,
        service_name: work_order.description,
        service_provider: work_order.vendor,
        invoice_amount: invoice.formatted_total,
        invoice_notes: invoice.notes&.to_s&.gsub(/\n/, '<br>')&.html_safe,
        payment_link: deep_link.to_s,
        approve_invoice_header: "You have an invoice ready for payment.",
      }.to_s)
    end
  end
end
