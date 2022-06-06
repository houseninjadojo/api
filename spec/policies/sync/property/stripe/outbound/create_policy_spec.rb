require "rails_helper"

RSpec.describe Sync::Property::Stripe::Outbound::CreatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:property) { create(:property) }

  let(:policy) { described_class.new(property) }

  describe_rule :can_sync? do
    it "returns true if all conditions match" do
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions fail" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    it "returns true if property.user has external id" do
      property.user.stripe_id = "cus_123"
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if ruser does not have external id" do
      property.user.stripe_id = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end
end
