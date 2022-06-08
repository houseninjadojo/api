require 'rails_helper'

RSpec.describe Sync::WorkOrder::Hubspot::Outbound::UpdateJob, type: :job do
  let(:work_order) { create(:work_order) }
  let(:changeset) {
    [
      {
        path: [:status],
        old: work_order.status.slug,
        new: 'completed',
      }
    ]
  }
  let(:job) { Sync::WorkOrder::Hubspot::Outbound::UpdateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Hubspot::Deal).not_to receive(:update!)
      job.perform_now(work_order, changeset)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:work_order).and_return(work_order))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(work_order, changeset).params
      expect(Hubspot::Deal).to receive(:update!).with(work_order.hubspot_id, params)
      job.perform_now(work_order, changeset)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:work_order).at_least(:once).and_return(work_order))
      expect_any_instance_of(job).to(receive(:changeset).at_least(:once).and_return(changeset))
      expect(job.new(work_order, changeset).policy).to be_a(Sync::WorkOrder::Hubspot::Outbound::UpdatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Hubspot::Deal#update!" do
      allow_any_instance_of(job).to(receive(:work_order).and_return(work_order))
      expect(job.new(work_order, changeset).params).to eq({
        dealstage: work_order.status.slug,
        invoice_paid: "No"
      })
    end
  end
end
