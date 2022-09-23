require "rails_helper"

RSpec.describe Sync::Estimate::Hubspot::Outbound::UpdatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:estimate) { create(:estimate, approved_at: Time.current) }
  let(:changeset) {
    [
      {
        path: [:approved_at],
        old: estimate.approved_at,
        new: Time.current + 1.day,
      }
    ]
  }

  let(:policy) { described_class.new(estimate, changeset: changeset) }

  describe_rule :can_sync? do
    it "returns true if all conditions true" do
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:has_changed_attributes?).and_return(true)
      expect(policy).to receive(:has_present_attributes?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions false" do
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:has_changed_attributes?).and_return(true)
      expect(policy).to receive(:has_present_attributes?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    it "returns true if work_order has hubspot_id" do
      estimate.work_order.hubspot_id = "asdf"
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if work_order does not have hubspot_id" do
      estimate.work_order.hubspot_id = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :has_changed_attributes? do
    it "returns true if estimate has changed attributes" do
      estimate.update(approved_at: Time.current + 2.days)
      policy = described_class.new(estimate, changeset: changeset)
      expect(policy.has_changed_attributes?).to be_truthy
    end

    it "returns false if estimate does not have changed attributes" do
      estimate.update(approved_at: estimate.approved_at) # no-op
      policy = described_class.new(estimate, changeset: [])
      expect(policy.has_changed_attributes?).to be_falsey
    end
  end

  describe_rule :has_present_attributes? do
    it "returns true if estimate has present attributes" do
      expect(policy.has_present_attributes?).to be_truthy
    end

    it "returns false if estimate does not have present attributes" do
      estimate.update(approved_at: nil, declined_at: nil)
      policy = described_class.new(estimate, changeset: changeset)
      expect(policy.has_present_attributes?).to be_falsey
    end
  end
end
