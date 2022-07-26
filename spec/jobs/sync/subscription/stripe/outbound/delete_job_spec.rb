require 'rails_helper'

RSpec.describe Sync::Subscription::Stripe::Outbound::DeleteJob, type: :job do
  let(:resource) { create(:subscription) }

  let(:job) { Sync::Subscription::Stripe::Outbound::DeleteJob }

  describe "#perform" do
    xit "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Stripe::Subscription).not_to receive(:delete)
      job.perform_now(resource)
    end

    xit "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:resource).and_return(resource))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      expect(Stripe::Subscription).to receive(:delete).with(resource.stripe_id).and_return(
        double(status: 'canceled', canceled_at: Time.zone.now.to_i)
      )
      job.perform_now(resource)
      expect(resource.status).to eq('canceled')
      expect(resource.canceled_at).to be_within(1.second).of(Time.zone.now)
    end
  end

  describe "#policy" do
    xit "returns a Sync::PaymentMethod::Stripe::Outbound::DeletePolicy" do
      expect_any_instance_of(job).to(receive(:resource).at_least(:once).and_return(resource))
      expect(job.new(resource).policy).to be_a(Sync::PaymentMethod::Stripe::Outbound::DeletePolicy)
    end
  end
end
