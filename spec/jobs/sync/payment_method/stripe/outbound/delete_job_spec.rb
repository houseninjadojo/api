require 'rails_helper'

RSpec.describe Sync::PaymentMethod::Stripe::Outbound::DeleteJob, type: :job do
  let(:resource) { create(:payment_method) }

  let(:job) { Sync::PaymentMethod::Stripe::Outbound::DeleteJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Stripe::PaymentMethod).not_to receive(:detach)
      job.perform_now(resource)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:resource).and_return(resource))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      expect(Stripe::PaymentMethod).to receive(:detach).with(resource.stripe_id)
      job.perform_now(resource)
      expect(resource.stripe_id).to eq(nil)
    end
  end

  describe "#policy" do
    it "returns a Sync::PaymentMethod::Stripe::Outbound::DeletePolicy" do
      expect_any_instance_of(job).to(receive(:resource).at_least(:once).and_return(resource))
      expect(job.new(resource).policy).to be_a(Sync::PaymentMethod::Stripe::Outbound::DeletePolicy)
    end
  end
end
