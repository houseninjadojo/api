require 'rails_helper'

RSpec.describe Sync::WorkOrder::Hubspot::Inbound::CreateJob, type: :job do
  let(:work_order) {
    create(:work_order,
      hubspot_id: '123456789',
      status: WorkOrderStatus.find_by(slug: 'closed'),
    )
  }
  let(:payload) {
    [
      {
        "eventId"=>3561786325,
        "subscriptionId"=>1444072,
        "portalId"=>20553083,
        "appId"=>657827,
        "occurredAt"=>1654802227679,
        "subscriptionType"=>"deal.creation",
        "attemptNumber"=>0,
        "objectId"=>123456789,
        "changeFlag"=>"NEW",
        "changeSource"=>"CRM_UI"
      },
      {
        "eventId"=>4018909085,
        "subscriptionId"=>1444079,
        "portalId"=>20553083,
        "appId"=>657827,
        "occurredAt"=>1654802227679,
        "subscriptionType"=>"deal.propertyChange",
        "attemptNumber"=>0,
        "objectId"=>123456789,
        "propertyName"=>"createdate",
        "propertyValue"=>"1654802227679",
        "changeSource"=>"CRM_UI"
      },
      {
        "eventId"=>1128470173,
        "subscriptionId"=>1444076,
        "portalId"=>20553083,
        "appId"=>657827,
        "occurredAt"=>1654802227679,
        "subscriptionType"=>"deal.propertyChange",
        "attemptNumber"=>0,
        "objectId"=>123456789,
        "propertyName"=>"dealstage",
        "propertyValue"=>"15611951",
        "changeSource"=>"CRM_UI"
      },
      {
        "eventId"=>3259349419,
        "subscriptionId"=>1444077,
        "portalId"=>20553083,
        "appId"=>657827,
        "occurredAt"=>1654802227679,
        "subscriptionType"=>"deal.propertyChange",
        "attemptNumber"=>0,
        "objectId"=>123456789,
        "propertyName"=>"pipeline",
        "propertyValue"=>"2133042",
        "changeSource"=>"CRM_UI"
      },
      {
        "eventId"=>4041273303,
        "subscriptionId"=>1444074,
        "portalId"=>20553083,
        "appId"=>657827,
        "occurredAt"=>1654802227679,
        "subscriptionType"=>"deal.propertyChange",
        "attemptNumber"=>0,
        "objectId"=>123456789,
        "propertyName"=>"dealname",
        "propertyValue"=>"Water Line Leak",
        "changeSource"=>"CRM_UI"
      }
    ]
  }
  let(:webhook_event) {
    create(:webhook_event,
      service: 'hubspot',
      payload: payload
    )
  }
  let(:job) { Sync::WorkOrder::Hubspot::Inbound::CreateJob }
  let(:webhook_entry) { Hubspot::Webhook::Payload.new(webhook_event).deal_batch_entry }

  before do
    WorkOrderStatus.find_by(slug: 'work_request_received').update(hubspot_id: '15611951')
  end

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      # entry = Hubspot::Webhook::Entry.new(webhook_entry, webhook_event)
      expect(WorkOrder).not_to receive(:create!)
      job.perform_now(webhook_entry, webhook_event)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      payload = Hubspot::Webhook::Payload.new(webhook_event)
      expect(WorkOrder).to receive(:create!).with(payload.as_params)
      expect(webhook_event).to receive(:update!)
      job.perform_now(webhook_entry, webhook_event)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_entry, webhook_event).policy).to be_a(Sync::WorkOrder::Hubspot::Inbound::CreatePolicy)
    end
  end

  describe "#entry" do
    it "returns Hubspot::Webhook::Entry" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_entry, webhook_event).entry).to be_a(Hubspot::Webhook::Entry)
    end

    it "returns Hubspot::Webhook::Entry#resource_klass" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_entry, webhook_event).entry.resource_klass).to eq(WorkOrder)
    end
  end

  describe "#payload" do
    it "returns Hubspot::Webhook::Payload" do
      # expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_entry, webhook_event).payload).to be_a(Hubspot::Webhook::Payload)
    end

    it "returns Hubspot::Webhook::Payload#as_params" do
      # expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_entry, webhook_event).payload.as_params).to include(
        description: "Water Line Leak",
        status: WorkOrderStatus.find_by(slug: "work_order_initiated"),
        hubspot_id: "123456789"
      )
    end
  end
end
