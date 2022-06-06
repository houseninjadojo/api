require 'rails_helper'

RSpec.describe Sync::User::Stripe::Outbound::CreateJob, type: :job do
  let(:user) { create(:user) }

  let(:job) { Sync::User::Stripe::Outbound::CreateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Stripe::Customer).not_to receive(:create)
      job.perform_now(user)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(user).params
      expect(Stripe::Customer).to receive(:create).with(params).and_return(double(id: "customer_id"))
      job.perform_now(user)
      expect(user.stripe_id).to eq("customer_id")
    end
  end

  describe "#policy" do
    it "returns a Sync::User::Stripe::Outbound::CreatePolicy" do
      expect_any_instance_of(job).to(receive(:user).at_least(:once).and_return(user))
      expect(job.new(user).policy).to be_a(Sync::User::Stripe::Outbound::CreatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Stripe::Customer.create" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      expect(job.new(user).params).to eq({
        description: user.full_name,
        email: user.email,
        name: user.name,
        phone: user.phone_number
      })
    end
  end
end
