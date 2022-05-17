require 'rails_helper'

RSpec.describe Stripe::Invoices::CreateJob, type: :job do
  describe "#perform_*" do
    let(:user) { create(:user, :with_payment_method) }
    let(:invoice) { create(:invoice, user: user, stripe_id: nil) }
    let(:job) { Stripe::Invoices::CreateJob }
    let(:params) {
      {
        auto_advance: false,
        collection_method: "charge_automatically",
        customer: invoice.user.stripe_id,
        default_payment_method: invoice.user.default_payment_method.stripe_id,
        description: invoice.description,
        subscription: @invoice.try(:subscription).try(:stripe_id),
      }
    }
    let(:line_item_params) {
      {
        amount: invoice.total,
        currency: 'usd',
        customer: user.stripe_id,
      }
    }

    it "calls Stripe::Invoice.create" do
      expect(Stripe::InvoiceItem).to receive(:create).with(line_item_params).and_return(double(id: "stripe_id", as_json: {}))
      expect(Stripe::Invoice).to receive(:create).with(params).and_return(double(id: "stripe_id", as_json: {}))
      job.perform_now(invoice)
    end
  end
end
