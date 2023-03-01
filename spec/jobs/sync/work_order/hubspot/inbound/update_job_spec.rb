require 'rails_helper'

RSpec.describe Sync::WorkOrder::Hubspot::Inbound::UpdateJob, type: :job do
  let(:work_order) {
    create(:work_order,
      hubspot_id: '123456789',
      status: WorkOrderStatus.find_by(slug: 'closed'),
    )
  }
  let(:webhook_entry) {
    {
      "eventId"=>320936115,
      "subscriptionId"=>1444064,
      "portalId"=>20553083,
      "appId"=>657827,
      "occurredAt"=>1644204893172,
      "subscriptionType"=>"deal.propertyChange",
      "attemptNumber"=>0,
      "objectId"=>123456789,
      "propertyName"=>"dealstage",
      "propertyValue"=>"15611951",
      "changeSource"=>"FORM"
    }
  }
  let(:webhook_event) {
    create(:webhook_event,
      service: 'hubspot',
      payload: [webhook_entry]
    )
  }
  let(:job) { Sync::WorkOrder::Hubspot::Inbound::UpdateJob }

  before do
    WorkOrderStatus.find_by(slug: 'work_request_received').update(hubspot_id: '15611951')
    allow(WorkOrder).to(receive(:find_by).and_return(work_order))
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
      expect(work_order).to receive(:update!).with(
        entry.attribute_name => entry.attribute_value
      )
      expect(webhook_event).to receive(:update!)
      job.perform_now(webhook_event, webhook_entry)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event, webhook_entry).policy).to be_a(Sync::WorkOrder::Hubspot::Inbound::UpdatePolicy)
    end
  end

  describe "#entry" do
    it "returns Hubspot::Webhook::Entry" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event, webhook_entry).entry).to be_a(Hubspot::Webhook::Entry)
    end

    it "returns Hubspot::Webhook::Entry#attribute_name" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event, webhook_entry).entry.attribute_name).to eq(:status)
    end

    it "returns Hubspot::Webhook::Entry#attribute_value" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event, webhook_entry).entry.attribute_value).to eq(WorkOrderStatus.find_by(hubspot_id: "15611951"))
    end
  end
end
