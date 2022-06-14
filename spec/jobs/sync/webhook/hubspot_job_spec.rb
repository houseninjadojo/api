require 'rails_helper'

RSpec.describe Sync::Webhook::HubspotJob, type: :job do
  let(:payload) {
    [
      {
        "eventId"=>843593753,
        "subscriptionId"=>1444075,
        "portalId"=>20553083,
        "appId"=>657827,
        "occurredAt"=>1655169471738,
        "subscriptionType"=>"deal.propertyChange",
        "attemptNumber"=>0,
        "objectId"=>9144820241,
        "propertyName"=>"amount",
        "propertyValue"=>"5268.75",
        "changeSource"=>"CRM_UI",
      },
    ]
  }
  let(:webhook_event) {
    create(:webhook_event,
      service: 'hubspot',
      payload: payload
    )
  }
  let(:job) { Sync::Webhook::HubspotJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Sync::WorkOrder::Hubspot::Inbound::UpdateJob).not_to receive(:perform_later)
      job.perform_now(webhook_event)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to receive(:webhook_event).and_return(webhook_event)
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      expect(Sync::WorkOrder::Hubspot::Inbound::UpdateJob).to receive(:perform_later).with(webhook_event, webhook_event.payload.first)
      job.perform_now(webhook_event)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event).policy).to be_a(Sync::Webhook::HubspotPolicy)
    end
  end

  describe "#payload" do
    it "returns a hubspot payload" do
      allow_any_instance_of(job).to receive(:webhook_event).and_return(webhook_event)
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      expect(job.new(webhook_event).payload).to be_a(Hubspot::Webhook::Payload)
    end
  end
end
