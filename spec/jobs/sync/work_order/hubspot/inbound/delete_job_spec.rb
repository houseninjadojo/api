require 'rails_helper'

RSpec.describe Sync::WorkOrder::Hubspot::Inbound::DeleteJob, type: :job do
  let(:work_order) {
    create(:work_order,
      hubspot_id: '123456789',
      status: WorkOrderStatus.find_by(slug: 'closed'),
    )
  }
  let(:webhook_entry) {
    {
      "eventId":1385672591,
      "subscriptionId":1473275,
      "portalId":20553083,
      "appId":688184,
      "occurredAt":1658453971688,
      "subscriptionType":"deal.deletion",
      "attemptNumber":0,
      "objectId":123456789,
      "changeFlag":"DELETED",
      "changeSource":"HUBSPOT_INTERNAL"
    }
  }
  let(:webhook_event) {
    create(:webhook_event,
      service: 'hubspot',
      payload: [webhook_entry]
    )
  }
  let(:job) { Sync::WorkOrder::Hubspot::Inbound::DeleteJob }

  before do
    WorkOrderStatus.find_by(slug: 'work_request_received').update(hubspot_id: '15611951')
    allow(WorkOrder).to(receive(:find_by).and_return(work_order))
    @time_now = Time.now
    allow(Time).to receive(:now).and_return(@time_now)
  end

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      entry = Hubspot::Webhook::Entry.new(webhook_event, webhook_entry)
      expect(work_order).not_to receive(:update!)
      job.perform_now(webhook_event, webhook_entry)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      allow(WorkOrder).to receive(:find_by).and_return(work_order)
      entry = Hubspot::Webhook::Entry.new(webhook_event, webhook_entry)
      expect(work_order).to receive(:update!).with(a_hash_including(deleted_at: Time.now))
      expect(webhook_event).to receive(:update!)
      job.perform_now(webhook_event, webhook_entry)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event, webhook_entry).policy).to be_a(Sync::WorkOrder::Hubspot::Inbound::DeletePolicy)
    end
  end

  describe "#entry" do
    it "returns Hubspot::Webhook::Entry" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event, webhook_entry).entry).to be_a(Hubspot::Webhook::Entry)
    end

    it "returns Hubspot::Webhook::Entry#resource" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event, webhook_entry).entry.resource).to be_a(WorkOrder)
    end
  end
end
