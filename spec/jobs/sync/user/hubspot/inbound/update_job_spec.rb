require 'rails_helper'

RSpec.describe Sync::User::Hubspot::Inbound::UpdateJob, type: :job do
  let(:user) {
    create(:user,
      hubspot_id: '123456789',
      first_name: 'Bob',
    )
  }
  let(:webhook_entry) {
    {
      "eventId"=>320936115,
      "subscriptionId"=>1444064,
      "portalId"=>20553083,
      "appId"=>657827,
      "occurredAt"=>1644204893172,
      "subscriptionType"=>"contact.propertyChange",
      "attemptNumber"=>0,
      "objectId"=>123456789,
      "propertyName"=>"firstname",
      "propertyValue"=>"not bob",
      "changeSource"=>"FORM"
    }
  }
  let(:webhook_event) {
    create(:webhook_event,
      service: 'hubspot',
      payload: [webhook_entry]
    )
  }
  let(:job) { Sync::User::Hubspot::Inbound::UpdateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      entry = Hubspot::Webhook::Entry.new(webhook_event, webhook_entry)
      expect(user).not_to receive(:update!)
      job.perform_now(webhook_event, webhook_entry)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      entry = Hubspot::Webhook::Entry.new(webhook_event, webhook_entry)
      expect(user).to receive(:update!).with(
        entry.attribute_name => entry.attribute_value
      )
      expect(User).to receive(:find_by).and_return(user).at_least(:once)
      expect(webhook_event).to receive(:update!)
      job.perform_now(webhook_event, webhook_entry)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event, webhook_entry).policy).to be_a(Sync::User::Hubspot::Inbound::UpdatePolicy)
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
      expect(job.new(webhook_event, webhook_entry).entry.attribute_name).to eq(:first_name)
    end

    it "returns Hubspot::Webhook::Entry#attribute_value" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event, webhook_entry).entry.attribute_value).to eq("not bob")
    end
  end
end
