require "rails_helper"

RSpec.describe Sync::WorkOrder::Hubspot::Outbound::UpdatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:work_order) { create(:work_order) }
  # let(:new_work_order_status) {
  #   create(
  #     :work_order_status,
  #     name: "Invoice Paid By Customer",
  #     slug: "invoice_paid_by_customer",
  #     hubspot_id: "12345"
  #   )
  # }
  let(:changeset) {
    [
      {
        path: [:status],
        old: work_order.status.slug,
        new: 'invoice_paid_by_customere',
      }
    ]
  }
  let(:policy) { described_class.new(work_order, changeset: changeset) }

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
      work_order.update(status: WorkOrderStatus.find_by(slug: 'canceled'))
      policy = described_class.new(work_order, changeset: changeset)
      expect(policy.has_changed_attributes?).to be_truthy
    end

    it "returns false if work_order does not have changed attributes" do
      work_order.update(status: work_order.status) # no-op
      policy = described_class.new(work_order, changeset: [])
      expect(policy.has_changed_attributes?).to be_falsey
    end
  end
end
