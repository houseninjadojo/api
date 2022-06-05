require "rails_helper"

RSpec.describe Sync::Property::Stripe::OutboundPolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:property) { create(:property) }
  let(:changed_attributes) {
    {
      "street_address1": [property.street_address1, "New Street Address 1"],
      "updated_at": [property.updated_at, Time.zone.now],
    }
  }

  let(:policy) { described_class.new(property, changed_attributes: changed_attributes) }

  describe_rule :can_sync? do
    it "returns true if all conditions true" do
      expect(policy).to receive(:should_sync?).and_return(true)
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:has_changed_attributes?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions false" do
      expect(policy).to receive(:should_sync?).and_return(true)
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:has_changed_attributes?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :should_sync? do
    it "returns true if there are changes" do
      property.update(street_address1: "New Street Address 1")
      policy = described_class.new(property, changed_attributes: changed_attributes)
      expect(policy.should_sync?).to eq(true)
    end

    it "returns false if there are no changes" do
      policy = described_class.new(property, changed_attributes: changed_attributes)
      expect(policy.should_sync?).to eq(false)
    end
  end

  describe_rule :has_external_id? do
    it "returns true if user has stripe_customer_id" do
      property.user.stripe_customer_id = "asdf"
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if property.user does not have stripe_customer_id" do
      property.user.stripe_customer_id = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :has_changed_attributes? do
    it "returns true if property has changed attributes" do
      property.update(street_address1: "New Street Address 1")
      policy = described_class.new(property, changed_attributes: property.saved_changes)
      expect(policy.has_changed_attributes?).to be_truthy
    end

    it "returns false if user does not have changed attributes" do
      property.update(street_address1: property.street_address1) # no-op
      policy = described_class.new(property, changed_attributes: property.saved_changes)
      expect(policy.has_changed_attributes?).to be_falsey
    end
  end
end
