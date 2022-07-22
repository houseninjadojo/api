require "rails_helper"

RSpec.describe Sync::WorkOrder::Hubspot::Inbound::DeletePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:work_order) {
    create(:work_order,
      hubspot_id: '1234',
      status: WorkOrderStatus.find_by(slug: 'work_request_received'),
    )
  }
  let(:payload) {
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
      payload: [payload]
    )
  }
  let(:policy) { described_class.new(payload, webhook_event: webhook_event) }

  describe_rule :can_sync? do
    it "returns true if all conditions true" do
      expect(policy).to receive(:enabled?).and_return(true)
      expect(policy).to receive(:webhook_is_unprocessed?).and_return(true)
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:already_deleted?).and_return(false)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions false" do
      expect(policy).to receive(:enabled?).and_return(true)
      expect(policy).to receive(:webhook_is_unprocessed?).and_return(true)
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:already_deleted?).and_return(true)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    it "returns true if external id present" do
      payload["objectId"] = '1234'
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if external id not present" do
      payload["objectId"] = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :already_deleted? do
    before(:each) do
      @time_now = Time.now
      allow(Time).to receive(:now).and_return(@time_now)
    end

    it "returns true if attribute name valid" do
      work_order.deleted_at = Time.now
      allow_any_instance_of(Hubspot::Webhook::Entry).to receive(:resource).and_return(work_order)
      expect(policy.already_deleted?).to be_truthy
    end

    it "returns false if attribute name not valid" do
      allow_any_instance_of(Hubspot::Webhook::Entry).to receive(:resource).and_return(work_order)
      expect(policy.already_deleted?).to be_falsey
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
