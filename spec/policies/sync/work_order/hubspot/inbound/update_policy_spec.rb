require "rails_helper"

RSpec.describe Sync::WorkOrder::Hubspot::Inbound::UpdatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:work_order) {
    create(:work_order,
      hubspot_id: '1234',
      status: WorkOrderStatus::WORK_REQUEST_RECEIVED,
    )
  }
  let(:payload) {
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
      "propertyValue"=>"invoice_sent_to_customer",
      "changeSource"=>"FORM"
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
      expect(policy).to receive(:has_attribute_name?).and_return(true)
      expect(policy).to receive(:has_attribute_value?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions false" do
      expect(policy).to receive(:enabled?).and_return(true)
      expect(policy).to receive(:webhook_is_unprocessed?).and_return(true)
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:has_attribute_name?).and_return(true)
      expect(policy).to receive(:has_attribute_value?).and_return(false)
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

  describe_rule :has_attribute_name? do
    it "returns true if attribute name valid" do
      payload["propertyName"] = 'dealstage'
      expect(policy.has_attribute_name?).to be_truthy
    end

    it "returns false if attribute name not valid" do
      payload["propertyName"] = nil
      expect(policy.has_attribute_name?).to be_falsey
    end
  end

  describe_rule :has_attribute_value? do
    it "returns true if attribute value exists" do
      payload["propertyValue"] = 'asdf'
      expect(policy.has_attribute_value?).to be_truthy
    end

    it "returns true if attribute value is empty atring" do
      payload["propertyValue"] = ''
      expect(policy.has_attribute_value?).to be_truthy
    end

    it "returns false if attribute value nil" do
      payload["propertyValue"] = nil
      expect(policy.has_attribute_value?).to be_falsey
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
