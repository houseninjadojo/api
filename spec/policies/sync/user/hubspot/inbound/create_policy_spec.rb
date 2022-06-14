require "rails_helper"

RSpec.describe Sync::User::Hubspot::Inbound::CreatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  # let(:user) {
  #   create(:user,
  #     hubspot_id: '123456789',
  #     first_name: 'Bob',
  #   )
  # }
  let(:payload) {
    [
      {
        "eventId"=>3561786325,
        "subscriptionId"=>1444072,
        "portalId"=>20553083,
        "appId"=>657827,
        "occurredAt"=>1654802227679,
        "subscriptionType"=>"contact.creation",
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
        "subscriptionType"=>"contact.propertyChange",
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
        "subscriptionType"=>"contact.propertyChange",
        "attemptNumber"=>0,
        "objectId"=>123456789,
        "propertyName"=>"firstname",
        "propertyValue"=>"Bob",
        "changeSource"=>"CRM_UI"
      },
      {
        "eventId"=>3259349419,
        "subscriptionId"=>1444077,
        "portalId"=>20553083,
        "appId"=>657827,
        "occurredAt"=>1654802227679,
        "subscriptionType"=>"contact.propertyChange",
        "attemptNumber"=>0,
        "objectId"=>123456789,
        "propertyName"=>"lastname",
        "propertyValue"=>"Smith",
        "changeSource"=>"CRM_UI"
      },
      {
        "eventId"=>4041273303,
        "subscriptionId"=>1444074,
        "portalId"=>20553083,
        "appId"=>657827,
        "occurredAt"=>1654802227679,
        "subscriptionType"=>"contact.propertyChange",
        "attemptNumber"=>0,
        "objectId"=>123456789,
        "propertyName"=>"email",
        "propertyValue"=>"bob@bob.com",
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
  let(:policy) { described_class.new(payload, webhook_event: webhook_event) }

  describe_rule :can_sync? do
    it "returns true if all conditions true" do
      expect(policy).to receive(:enabled?).and_return(true)
      expect(policy).to receive(:webhook_is_unprocessed?).and_return(true)
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:is_create_event?).and_return(true)
      expect(policy).to receive(:is_new_record?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions false" do
      expect(policy).to receive(:enabled?).and_return(true)
      expect(policy).to receive(:webhook_is_unprocessed?).and_return(true)
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:is_create_event?).and_return(true)
      expect(policy).to receive(:is_new_record?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    it "returns true if external id present" do
      payload.first["objectId"] = '1234'
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if external id not present" do
      payload.first["objectId"] = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :is_create_event? do
    it "returns true if payload contains a create event" do
      expect(policy.is_create_event?).to be_truthy
    end

    it "returns false if attribute name not valid" do
      webhook_event.payload = payload.select { |p| p["subscriptionType"] == "contact.propertyChange" }
      expect(policy.is_create_event?).to be_falsey
    end
  end

  describe_rule :is_new_record? do
    it "returns true if resource does not exist" do
      expect(policy.is_new_record?).to be_truthy
    end

    it "returns false if resource already exits" do
      user = create(:user, hubspot_id: '123456789')
      expect(policy.is_new_record?).to be_falsey
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
