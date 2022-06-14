require "rails_helper"

RSpec.describe Sync::Webhook::HubspotPolicy, type: :policy do
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
  let(:policy) { described_class.new(webhook_event) }

  describe_rule :can_sync? do
    it "returns true if all conditions true" do
      expect(policy).to receive(:webhook_is_unprocessed?).and_return(true)
      expect(policy).to receive(:enabled?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions false" do
      expect(policy).to receive(:webhook_is_unprocessed?).and_return(false)
      expect(policy).to receive(:enabled?).and_return(true)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :webhook_is_unprocessed? do
    it "returns true if webhook is unprocessed" do
      webhook_event.processed_at = nil
      expect(policy.webhook_is_unprocessed?).to be_truthy
    end

    it "returns false if webhook was already processed" do
      webhook_event.processed_at = Time.now
      expect(policy.webhook_is_unprocessed?).to be_falsey
    end
  end

  describe_rule :enabled? do
    it "returns true if handler enabled" do
      allow(ENV).to receive(:[]).with('HUBSPOT_WEBHOOK_DISABLED').and_return(nil)
      expect(policy.enabled?).to be_truthy
    end

    it "returns false if handler disabled" do
      allow(ENV).to receive(:[]).with('HUBSPOT_WEBHOOK_DISABLED').and_return("true")
      expect(policy.enabled?).to be_falsey
    end
  end
end
