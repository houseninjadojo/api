require "rails_helper"

RSpec.describe Sync::WorkOrder::Hubspot::Outbound::UpdatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:work_order) { create(:work_order) }
  let(:new_work_order_status) {
    create(
      :work_order_status,
      name: "Invoice Paid By Customer",
      slug: "invoice_paid_by_customer",
      hubspot_id: "12345"
    )
  }
  let(:changed_attributes) {
    {
      "status": [work_order.status.slug, new_work_order_status.slug],
      "updated_at": [work_order.updated_at, Time.zone.now],
    }
  }

  let(:policy) { described_class.new(work_order, changed_attributes: changed_attributes) }

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
      work_order.update(status: new_work_order_status)
      policy = described_class.new(work_order, changed_attributes: changed_attributes)
      expect(policy.should_sync?).to eq(true)
    end

    it "returns false if there are no changes" do
      policy = described_class.new(work_order, changed_attributes: changed_attributes)
      expect(policy.should_sync?).to eq(false)
    end
  end

  describe_rule :has_external_id? do
    it "returns true if work_order has hubspot id" do
      work_order.hubspot_id = "cus_123"
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if work_order does not have hubspot id" do
      work_order.hubspot_id = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :has_changed_attributes? do
    it "returns true if work_order has changed attributes" do
      work_order.update(status: new_work_order_status)
      policy = described_class.new(work_order, changed_attributes: work_order.saved_changes)
      expect(policy.has_changed_attributes?).to be_truthy
    end

    it "returns false if work_order does not have changed attributes" do
      work_order.update(status: work_order.status) # no-op
      policy = described_class.new(work_order, changed_attributes: work_order.saved_changes)
      expect(policy.has_changed_attributes?).to be_falsey
    end
  end
end
