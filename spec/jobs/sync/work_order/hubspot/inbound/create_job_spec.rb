require 'rails_helper'

RSpec.describe Sync::WorkOrder::Hubspot::Inbound::CreateJob, type: :job do
  let(:work_order) {
    create(:work_order,
      hubspot_id: '123456789',
      status: WorkOrderStatus::CLOSED,
    )
  }
  let(:user) {
    create(:user,
      hubspot_id: '12345'
    )
  }
  let(:property) {
    create(:property,
      user: user
    )
  }
  let(:deal) {
    {
      "hs_closed_amount_in_home_currency"=>"0",
      "hs_analytics_latest_source_contact"=>"DIRECT_TRAFFIC",
      "dealname"=>"Water Line Leak",
      "profit_calculated_at_20_____"=>"0.25",
      "num_associated_contacts"=>"1",
      "hs_num_associated_deal_registrations"=>"0",
      "invoice_from_vendor"=>"1",
      "createdate"=>"1654802227679",
      "hs_is_closed"=>"false",
      "hs_analytics_latest_source_data_1"=>"www.houseninja.co/",
      "homeowner_name"=>"Miles  Zimmerman",
      "hs_deal_stage_probability"=>"0.1000000000000000055511151231257827021181583404541015625",
      "days_to_close"=>"0",
      "line_items_updated_at"=>"1",
      "invoice_for_homeowner"=>"1.25",
      "hs_deal_stage_probability_shadow"=>"0.1000000000000000055511151231257827021181583404541015625",
      "hs_analytics_latest_source_timestamp"=>"1649654324909",
      "hubspot_owner_id"=>"96652165",
      "hs_closed_amount"=>"0",
      "hs_analytics_source"=>"OFFLINE",
      "hs_created_by_user_id"=>"25885335",
      "hs_createdate"=>"1654802227679",
      "hs_projected_amount"=>"",
      "hs_is_deal_split"=>"false",
      "hs_num_target_accounts"=>"0",
      "hs_all_owner_ids"=>"96652165",
      "hs_projected_amount_in_home_currency"=>"",
      "hs_analytics_latest_source_data_1_contact"=>"www.houseninja.co/",
      "hs_is_closed_won"=>"false",
      "hs_analytics_latest_source_timestamp_contact"=>"1649654324909",
      "hs_user_ids_of_all_owners"=>"25885335",
      "hs_num_associated_active_deal_registrations"=>"0",
      "pipeline"=>"2133042",
      "hs_lastmodifieddate"=>"1656405840530",
      "hubspot_owner_assigneddate"=>"1656405797443",
      "hs_num_associated_deal_splits"=>"0",
      "dealstage"=>"15611951",
      "hs_object_id"=>"123456789",
      "hs_analytics_source_data_2"=>"41074",
      "hs_analytics_source_data_1"=>"INTEGRATION",
      "hs_analytics_latest_source"=>"DIRECT_TRAFFIC",
      "hs_updated_by_user_id"=>"25885335"
    }.with_indifferent_access
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
    xit "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      # entry = Hubspot::Webhook::Entry.new(webhook_event, webhook_entry)
      expect(WorkOrder).not_to receive(:create!)
      job.perform_now(webhook_event, webhook_entry)
    end

    xit "will sync if policy approves" do
      allow(Hubspot::Association).to receive(:all).and_return([double(id: '12345')])
      allow(Hubspot::Deal).to receive(:find).and_return(deal)
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      allow(user).to receive(:default_property).and_return(property)
      payload = Hubspot::Webhook::Payload.new(webhook_event)
      expect(WorkOrder).to receive(:create!).with({
        description: "Water Line Leak",
        status: WorkOrderStatus::WORK_ORDER_INITIATED,
        hubspot_id: "123456789",
        created_at: Time.at(1654802227679 / 1000),
        property: property,
      })
      expect(webhook_event).to receive(:update!)
      job.perform_now(webhook_event, webhook_entry)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event, webhook_entry).policy).to be_a(Sync::WorkOrder::Hubspot::Inbound::CreatePolicy)
    end
  end

  describe "#entry" do
    it "returns Hubspot::Webhook::Entry" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event, webhook_entry).entry).to be_a(Hubspot::Webhook::Entry)
    end

    it "returns Hubspot::Webhook::Entry#resource_klass" do
      expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event, webhook_entry).entry.resource_klass).to eq(WorkOrder)
    end
  end

  describe "#payload" do
    it "returns Hubspot::Webhook::Payload" do
      # expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event, webhook_entry).payload).to be_a(Hubspot::Webhook::Payload)
    end

    it "returns Hubspot::Webhook::Payload#as_params" do
      # expect_any_instance_of(job).to(receive(:webhook_entry).at_least(:once).and_return(webhook_entry))
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event, webhook_entry).payload.as_params).to include(
        description: "Water Line Leak",
        status: WorkOrderStatus::WORK_ORDER_INITIATED,
        hubspot_id: "123456789"
      )
    end
  end
end
