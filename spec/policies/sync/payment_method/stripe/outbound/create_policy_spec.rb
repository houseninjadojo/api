require "rails_helper"

RSpec.describe Sync::PaymentMethod::Stripe::Outbound::CreatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:resource) { create(:payment_method) }

  let(:policy) { described_class.new(resource) }

  describe_rule :can_sync? do
    it "returns true if all conditions match" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy).to receive(:user_has_external_id?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions fail" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy).to receive(:user_has_external_id?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    it "returns true if resource has external id" do
      resource.stripe_token = "cus_123"
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if resource does not have external id" do
      resource.stripe_token = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :user_has_external_id? do
    it "returns true if resource user has external id" do
      resource.user.stripe_id = "cus_123"
      expect(policy.user_has_external_id?).to be_truthy
    end

    it "returns false if resource user does not have external id" do
      resource.user.stripe_id = nil
      expect(policy.user_has_external_id?).to be_falsey
    end
  end
end
