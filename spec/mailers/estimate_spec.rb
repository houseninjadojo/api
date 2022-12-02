require "rails_helper"

RSpec.describe EstimateMailer, type: :mailer do
  describe "estimate_approval" do
    let(:user) { create(:user) }
    let(:work_order) { create(:work_order) }
    let(:deep_link) { create(:deep_link, url: "https://app.houseninja.co/estimate-link") }
    let(:estimate) { create(:estimate, work_order: work_order, deep_link: deep_link) }
    let(:mail) {
      EstimateMailer.with(
        estimate: estimate,
        user: user,
      ).estimate_approval
    }
    # let(:mail) { InvoiceMailer.payment_approval }

    it "calls sendgrid" do
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["hello@houseninja.co"])
      expect(mail.body).to eq('')
      expect(mail[:'template-id'].to_s).to eq('d-63a05b08f1ab43a3865811ef9509a2fc')
      expect(mail[:dynamic_template_data].value).to eq({
        subject: "You have an estimate ready for #{work_order.description}",
        first_name: user.first_name,
        app_store_url: Rails.settings.app_store_url,
        service_name: work_order.description,
        service_provider: work_order.vendor,
        estimate_amount_or_actual_estimate_if_populated: estimate.formatted_total,
        estimate_notes: estimate.description,
        estimate_link: deep_link.to_s,
        approve_estimate_header: "You have an estimate ready for review."
      }.to_s)
    end
  end
end
