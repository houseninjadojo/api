require 'rails_helper'

RSpec.describe Sync::WorkOrder::Arrivy::Outbound::CreateJob, type: :job do
  let(:user) { create(:user, arrivy_id: '1234') }
  let(:property) { create(:property, user: user) }
  let(:work_order) { create(:work_order, property: property) }

  let(:job) { Sync::WorkOrder::Arrivy::Outbound::CreateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect_any_instance_of(Arrivy::Task).not_to receive(:create)
      job.perform_now(work_order)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:work_order).and_return(work_order))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(work_order).params
      expect_any_instance_of(Arrivy::Task).to receive(:create).and_return(double(id: "1234"))
      job.perform_now(work_order)
      expect(work_order.arrivy_id).to eq("1234")
    end
  end

  describe "#policy" do
    it "returns a Sync::WorkOrder::Arrivy::Outbound::CreatePolicy" do
      expect_any_instance_of(job).to(receive(:work_order).at_least(:once).and_return(work_order))
      expect(job.new(work_order).policy).to be_a(Sync::WorkOrder::Arrivy::Outbound::CreatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Arrivy::Task#create" do
      allow_any_instance_of(job).to(receive(:work_order).and_return(work_order))
      expect(job.new(work_order).params).to eq({
        title: work_order.description,
        start_datetime: work_order.scheduled_window_start&.iso8601,
        end_datetime: work_order.scheduled_window_end&.iso8601,
        customer_id: work_order.user&.arrivy_id,
        external_id: work_order.id,
      })
    end
  end
end
