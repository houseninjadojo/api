require "rails_helper"

RSpec.describe Sync::User::Stripe::Outbound::CreatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:user) { create(:user) }

  let(:policy) { described_class.new(user) }

  describe_rule :can_sync? do
    it "returns true if all conditions match" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy).to receive(:ready_to_create?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions fail" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy).to receive(:ready_to_create?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    it "returns true if user has stripe customer id" do
      user.stripe_id = "cus_123"
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if user does not have stripe customer id" do
      user.stripe_id = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :ready_to_create? do
    it "returns true if right onboarding step" do
      user.onboarding_step = "payment-method"
      expect(policy.ready_to_create?).to be_truthy
    end

    it "returns false if not right onboarding step" do
      user.onboarding_step = "contact-info"
      expect(policy.ready_to_create?).to be_falsey
    end
  end
end
