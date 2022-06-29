require "rails_helper"

RSpec.describe Sync::User::Hubspot::Outbound::CreatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:user) { create(:user) }

  let(:policy) { described_class.new(user) }

  describe_rule :can_sync? do
    it "returns true if all conditions match" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy).to receive(:should_sync?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions fail" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy).to receive(:should_sync?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    it "returns true if user has external id" do
      user.hubspot_id = "cus_123"
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if user does not have external id" do
      user.hubspot_id = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :should_sync? do
    it "returns true" do
      expect(policy.should_sync?).to be_truthy
    end

    # it "returns false if user onboarding_step is not WELCOME" do
    #   user.onboarding_step = OnboardingStep::CONTACT_INFO
    #   expect(policy.should_sync?).to be_falsey
    # end
  end
end
