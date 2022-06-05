require 'rails_helper'

RSpec.describe Sync::WorkOrder::Hubspot::OutboundJob, type: :job do
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
  let(:job) { Sync::WorkOrder::Hubspot::OutboundJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Hubspot::Deal).not_to receive(:update!)
      job.perform_now(work_order, changed_attributes)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:work_order).and_return(work_order))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(work_order, changed_attributes).params
      expect(Hubspot::Deal).to receive(:update!).with(work_order.hubspot_id, params)
      job.perform_now(work_order, changed_attributes)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:work_order).at_least(:once).and_return(work_order))
      expect_any_instance_of(job).to(receive(:changed_attributes).at_least(:once).and_return(changed_attributes))
      expect(job.new(work_order, changed_attributes).policy).to be_a(Sync::WorkOrder::Hubspot::OutboundPolicy)
    end
  end

  describe "#params" do
    it "returns params for Hubspot::Deal#update!" do
      allow_any_instance_of(job).to(receive(:work_order).and_return(work_order))
      expect(job.new(work_order, changed_attributes).params).to eq({
        dealstage: work_order.status.slug,
        invoice_paid: "No"
      })
    end
  end
end
