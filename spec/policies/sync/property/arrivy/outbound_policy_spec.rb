require "rails_helper"

RSpec.describe Sync::Property::Arrivy::OutboundPolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:property) { create(:property) }
  let(:changeset) {
    [
      {
        path: [:street_address1],
        old: property.street_address1,
        new: 'new street address 1',
      }
    ]
  }
  let(:policy) { described_class.new(property, changeset: changeset) }

  describe_rule :can_sync? do
    it "returns true if all conditions true" do
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:has_changed_attributes?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions false" do
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:has_changed_attributes?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    it "returns true if user has arrivy id" do
      property.user.arrivy_id = "asdf"
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if property.user does not have arrivy id" do
      property.user.arrivy_id = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :has_changed_attributes? do
    it "returns true if property has changed attributes" do
      property.update(street_address1: "New Street Address 1")
      policy = described_class.new(property, changeset: changeset)
      expect(policy.has_changed_attributes?).to be_truthy
    end

    it "returns false if user does not have changed attributes" do
      property.update(street_address1: property.street_address1) # no-op
      policy = described_class.new(property, changeset: [])
      expect(policy.has_changed_attributes?).to be_falsey
    end
  end
end
