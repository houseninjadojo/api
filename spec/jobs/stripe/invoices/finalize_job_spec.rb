require 'rails_helper'

RSpec.describe Stripe::Invoices::FinalizeJob, type: :job do
  describe "#perform_*" do
    let(:user) { create(:user, :with_payment_method) }
    let(:invoice) { create(:invoice, user: user, finalized_at: nil) }
    let(:job) { Stripe::Invoices::FinalizeJob }

    xit "calls Stripe::Invoice.finalize" do
      expect(Stripe::Invoice).to receive(:finalize_invoice).with(invoice.stripe_id, { auto_advance: false })
      job.perform_now(invoice)
    end
  end
end
