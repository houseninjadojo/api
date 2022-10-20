require "rails_helper"

RSpec.describe EstimateMailer, type: :mailer do
  describe "estimate_approval" do
    let(:user) { create(:user) }
    let(:work_order) { create(:work_order) }
    let(:estimate) { create(:estimate, work_order: work_order) }
    let(:mail) {
      EstimateMailer.estimate_approval(
        estimate: estimate,
        user: user,
      )
    }
    # let(:mail) { InvoiceMailer.payment_approval }

    it "calls sendgrid" do
      expect(mail.to).to eq(["test@houseninja.co"])
      expect(mail.from).to eq(["hello@houseninja.co"])
      expect(mail.body).to eq('')
      expect(mail[:'template-id'].to_s).to eq('d-63a05b08f1ab43a3865811ef9509a2fc')
      expect(mail[:dynamic_template_data].value).to eq({
        subject: "You have an estimate ready for Test Service",
        first_name: "Test",
        service_name: "Test Service",
        service_provider: "Test Provider",
        estimate_amount_or_actual_estimate_if_populated: "$100.00",
        estimate_notes: "test<br>notest",
        estimate_link: "https://app.houseninja.co/estimate-link",
        app_store_url: "https://itunes.apple.com/us/app/houseninja/123456789"
      }.to_s)
    end
  end
end
