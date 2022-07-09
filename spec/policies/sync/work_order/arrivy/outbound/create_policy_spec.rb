require "rails_helper"

RSpec.describe Sync::WorkOrder::Arrivy::Outbound::CreatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:work_order) { create(:work_order) }

  let(:policy) { described_class.new(work_order) }

  describe_rule :can_sync? do
    it "returns true if all conditions match" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy).to receive(:has_start_datetime?).and_return(true)
      expect(policy).to receive(:should_sync?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end

    it "returns false if any conditions fail" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy).to receive(:has_start_datetime?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    it "returns true if work_order has arrivy id" do
      work_order.arrivy_id = "1234"
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if work_order does not arrivy id" do
      work_order.arrivy_id = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :has_start_datetime? do
    it "returns true if work order has scheduled_window_start" do
      work_order.scheduled_window_start = Time.now
      expect(policy.has_start_datetime?).to be_truthy
    end

    it "returns false if work order does not have scheduled_window_start" do
      work_order.scheduled_window_start = nil
      expect(policy.has_start_datetime?).to be_falsey
    end
  end
end
