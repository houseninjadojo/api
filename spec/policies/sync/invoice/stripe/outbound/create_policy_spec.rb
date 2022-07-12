require "rails_helper"

RSpec.describe Sync::Invoice::Stripe::Outbound::CreatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:user) { build(:user) }
  let(:payment_method) { build(:credit_card, user: user) }
  let(:subscription) { build(:subscription, user: user) }
  let(:work_order) { build(:work_order) }
  let(:resource) { build(:invoice, user: user, subscription: subscription, work_order: work_order) }

  let(:policy) { described_class.new(resource) }

  describe_rule :can_sync? do
    it "returns true if all conditions match" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy).to receive(:has_customer_id?).and_return(true)
      expect(policy).to receive(:has_payment_method_id?).and_return(false)
      expect(policy).to receive(:has_subscription_id?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions fail" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy).to receive(:has_customer_id?).and_return(true)
      expect(policy).to receive(:has_payment_method_id?).and_return(false)
      expect(policy).to receive(:has_subscription_id?).and_return(false)
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

  describe_rule :has_payment_method_id? do
    xit "returns true if resource payment_method has stripe id" do
      payment_method.stripe_token = "cus_123"
      resource.user.payment_methods << payment_method
      expect_any_instance_of(resource.user.default_payment_method).to receive(:stripe_id).and_return("cus_123")
      # resource.user.default_payment_method
      expect(policy.has_payment_method_id?).to be_truthy
    end

    it "returns false if resource payment_method does not have stripe id" do
      payment_method.stripe_token = nil
      resource.user.payment_methods << payment_method
      # resource.user.default_payment_method.stripe_token = nil
      expect(policy.has_payment_method_id?).to be_falsey
    end
  end

  describe_rule :has_subscription_id? do
    it "returns true if resource subscription has stripe id" do
      resource.subscription.stripe_id = "cus_123"
      expect(policy.has_subscription_id?).to be_truthy
    end

    it "returns false if resource subscription does not have stripe id" do
      resource.subscription.stripe_id = nil
      expect(policy.has_subscription_id?).to be_falsey
    end
  end

  describe_rule :is_walkthrough? do
    it "returns true if resource is_walkthrough" do
      resource.work_order.description = "Home Walkthrough: asdf"
      expect(policy.is_walkthrough?).to be_truthy
    end

    it "returns false if resource not is_walkthrough" do
      resource.work_order.description = "Not home walkthrough"
      expect(policy.is_walkthrough?).to be_falsey
    end
  end
end
