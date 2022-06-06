require "rails_helper"

RSpec.describe Sync::Subscription::Stripe::Outbound::CreatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:resource) { create(:subscription) }

  let(:policy) { described_class.new(resource) }

  describe_rule :can_sync? do
    it "returns true if all conditions match" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy).to receive(:has_customer_id?).and_return(true)
      expect(policy).to receive(:has_price_id?).and_return(true)
      expect(policy).to receive(:has_payment_method_id?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions fail" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    it "returns true if resource has external id" do
      resource.stripe_id = "cus_123"
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if resource does not have external id" do
      resource.stripe_id = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :has_customer_id? do
    it "returns true if resource user has external id" do
      resource.user.stripe_id = "cus_123"
      expect(policy.has_customer_id?).to be_truthy
    end

    it "returns false if resource user does not have external id" do
      resource.user.stripe_id = nil
      expect(policy.has_customer_id?).to be_falsey
    end
  end

  describe_rule :has_price_id? do
    it "returns true if resource subscription plan has price id" do
      resource.subscription_plan.stripe_price_id = "cus_123"
      expect(policy.has_price_id?).to be_truthy
    end

    it "returns false if resource subscription plan does not have price id" do
      resource.subscription_plan.stripe_price_id = nil
      expect(policy.has_price_id?).to be_falsey
    end
  end

  describe_rule :has_payment_method_id? do
    it "returns true if resource payment_method has stripe id" do
      resource.payment_method.stripe_id = "cus_123"
      expect(policy.has_payment_method_id?).to be_truthy
    end

    it "returns false if resource payment_method does not have stripe id" do
      resource.payment_method.stripe_id = nil
      expect(policy.has_payment_method_id?).to be_falsey
    end
  end
end
