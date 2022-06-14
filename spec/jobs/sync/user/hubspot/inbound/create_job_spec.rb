require 'rails_helper'

RSpec.describe Sync::User::Hubspot::Inbound::CreateJob, type: :job do
  let(:user) {
    create(:user,
      hubspot_id: '123456789',
      first_name: 'Bob',
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
  let(:job) { Sync::User::Hubspot::Inbound::CreateJob }
  let(:webhook_entry) { Hubspot::Webhook::Payload.new(webhook_event).create_batch_entry }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      # entry = Hubspot::Webhook::Entry.new(webhook_entry, webhook_event)
      expect(User).not_to receive(:create!)
      job.perform_now(webhook_entry, webhook_event)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      payload = Hubspot::Webhook::Payload.new(webhook_event)
      expect(User).to receive(:create!).with(payload.as_params)
      expect(webhook_event).to receive(:update!)
      job.perform_now(webhook_entry, webhook_event)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_entry, webhook_event).policy).to be_a(Sync::User::Hubspot::Inbound::CreatePolicy)
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
      expect(job.new(webhook_entry, webhook_event).entry.resource_klass).to eq(User)
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
        first_name: "Bob",
        last_name: "Smith",
        email: "bob@bob.com",
        hubspot_id: '123456789',
      )
    end
  end
end
