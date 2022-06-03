require 'rails_helper'

RSpec.describe Sync::User::StripeJob, type: :job do
  let(:user) { create(:user) }
  let(:changed_attributes) {
    {
      "first_name": [user.first_name, "New First Name"],
      "updated_at": [user.updated_at, Time.zone.now],
    }
  }
  let(:job) { Sync::User::StripeJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Stripe::Customer).not_to receive(:update)
      job.perform_now(user, changed_attributes)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(user, changed_attributes).params
      expect(Stripe::Customer).to receive(:update).with(user.stripe_customer_id, params)
      job.perform_now(user, changed_attributes)
    end
  end

  describe "#policy" do
    it "returns a Sync::User::StripePolicy" do
      expect_any_instance_of(job).to(receive(:user).at_least(:once).and_return(user))
      expect_any_instance_of(job).to(receive(:changed_attributes).at_least(:once).and_return(changed_attributes))
      expect(job.new(user, changed_attributes).policy).to be_a(Sync::User::StripePolicy)
    end
  end

  describe "#params" do
    it "returns params for Stripe::Customer.update" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      expect(job.new(user, changed_attributes).params).to eq({
        description: user.full_name,
        email: user.email,
        name: user.name,
        phone: user.phone_number
      })
    end
  end
end
