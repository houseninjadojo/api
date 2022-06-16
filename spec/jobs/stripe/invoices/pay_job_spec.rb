require 'rails_helper'

RSpec.describe Stripe::Invoices::PayJob, type: :job do
  describe "#perform_*" do
    let(:invoice) { create(:invoice, :finalized, :with_payment) }
    let(:job) { Stripe::Invoices::PayJob }
    let(:params) { { payment_method: invoice.user.default_payment_method.stripe_token } }

    xit "calls Stripe::Invoice.pay" do
      expect(Stripe::Invoice).to receive(:pay).with(invoice.stripe_id, params)
      Stripe::Invoices::PayJob.perform_now(invoice)
    end
  end
end
