# frozen_string_literal: true

require 'rails_helper'

require_relative '../../../../app/lib/hubspot/webhook/entry'

RSpec.describe Hubspot::Webhook::Entry do
  let(:work_order_status) {
    create(:work_order_status,
      slug: "work_order_initiated",
      name: "Work Order Initiated",
      hubspot_id: "15611951",
    )
  }
  let(:work_order) { create(:work_order,
      hubspot_id: '123456789',
      status: WorkOrderStatus.find_by(slug: 'work_request_received'),
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
      "propertyValue"=>"15611951",
      "changeSource"=>"FORM"
    }
  }
  let(:webhook_event) {
    create(:webhook_event,
      service: 'hubspot',
      payload: [payload]
    )
  }
  let(:entry) { Hubspot::Webhook::Entry.new(payload, webhook_event) }

  describe '.initialize' do
    it 'accepts webhook payload and event' do
      expect(entry.payload).to eq(payload)
    end
  end

  describe '#handler' do
    it 'returns the handler job when it exists' do
      expect(entry.handler).to eq(Sync::WorkOrder::Hubspot::Inbound::UpdateJob)
    end

    it 'returns nil if it does not exist' do
      entry.payload['subscriptionType'] = 'asdf.creation'
      expect(entry.handler).to eq(nil)
    end
  end

  describe '#handler_action' do
    it 'returns handler action when exists' do
      entry.payload["subscriptionType"] = "deal.creation"
      expect(entry.handler_action).to eq(:create)
      entry.payload["subscriptionType"] = "deal.propertyChange"
      expect(entry.handler_action).to eq(:update)
      entry.payload["subscriptionType"] = "contact.deletion"
      expect(entry.handler_action).to eq(:delete)
    end

    it 'returns nil if it does not exist' do
      entry.payload['subscriptionType'] = 'contact.privacyDeletion'
      expect(entry.handler_action).to eq(nil)
    end
  end

  describe '#resource_klass' do
    it 'returns resource class' do
      entry.payload["subscriptionType"] = "contact.creation"
      expect(entry.resource_klass).to eq(User)
      entry.payload["subscriptionType"] = "deal.propertyChange"
      expect(entry.resource_klass).to eq(WorkOrder)
    end

    it 'returns nil if it does not exist' do
      entry.payload['subscriptionType'] = 'company.creation'
      expect(entry.resource_klass).to eq(nil)
    end
  end

  describe '#resource' do
    it 'returns resource if exists' do
      expect(WorkOrder).to receive(:find_by).with(hubspot_id: '123456789').and_return(work_order)
      expect(entry.resource).to eq(work_order)
    end

    it 'returns nil if it does not exist' do
      entry.payload['objectId'] = 'bad_id'
      expect(entry.resource).to eq(nil)
    end
  end

  describe '#occured_at' do
    it 'returns parsed timestamp' do
      expect(entry.occured_at).to eq(Time.at(payload["occurredAt"].to_i / 1000))
    end
  end

  describe '#hubspot_id' do
    it 'returns hubspot id' do
      expect(entry.hubspot_id).to eq(payload["objectId"].to_s)
    end
  end

  describe '#id' do
    it 'returns hubspot id' do
      expect(entry.id).to eq(payload["objectId"].to_s)
    end
  end

  describe '#property_name' do
    it 'returns attribute' do
      expect(entry.property_name).to eq(payload["propertyName"])
    end
  end

  describe '#property_value' do
    it 'returns value' do
      expect(entry.property_value).to eq(payload["propertyValue"])
    end
  end

  describe '#attribute_name' do
    it 'amount => total' do
      entry.payload["propertyName"] = "amount"
      expect(entry.attribute_name).to eq(:total)
    end

    it 'closedate => nil' do
      entry.payload["propertyName"] = "closedate"
      expect(entry.attribute_name).to be_nil
    end

    it 'closed_lost_reason => nil' do
      entry.payload["propertyName"] = "closed_lost_reason"
      expect(entry.attribute_name).to be_nil
    end

    it 'closed_won_reason => nil' do
      entry.payload["propertyName"] = "closed_won_reason"
      expect(entry.attribute_name).to be_nil
    end

    it 'createdate => created_at' do
      entry.payload["propertyName"] = "createdate"
      expect(entry.attribute_name).to eq(:created_at)
    end

    it 'date_estimate_sent => sent_at' do
      entry.payload["propertyName"] = "date_estimate_sent"
      expect(entry.attribute_name).to eq(:sent_at)
    end

    it 'dealname => description' do
      entry.payload["propertyName"] = "dealname"
      expect(entry.attribute_name).to eq(:description)
    end

    it 'dealstage => status' do
      entry.payload["propertyName"] = "dealstage"
      expect(entry.attribute_name).to eq(:status)
    end

    it 'dealtype => nil' do
      entry.payload["propertyName"] = "dealtype"
      expect(entry.attribute_name).to be_nil
    end

    it 'description => nil' do
      entry.payload["propertyName"] = "description"
      expect(entry.attribute_name).to be_nil
    end

    it 'estimate_approved => approved' do
      entry.payload["propertyName"] = "estimate_approved"
      expect(entry.attribute_name).to eq(:approved)
    end

    it 'estimate___for_homeowner => nil' do
      entry.payload["propertyName"] = "estimate___for_homeowner"
      expect(entry.attribute_name).to be_nil
    end

    it 'estimate___from_vendor => nil' do
      entry.payload["propertyName"] = "estimate___from_vendor"
      expect(entry.attribute_name).to be_nil
    end

    it 'hs_lastmodifieddate => nil' do
      entry.payload["propertyName"] = "hs_lastmodifieddate"
      expect(entry.attribute_name).to eq(:updated_at)
    end

    it 'invoice_for_homeowner => homeowner_amount' do
      entry.payload["propertyName"] = "invoice_for_homeowner"
      expect(entry.attribute_name).to eq(:homeowner_amount)
    end

    it 'invoice_from_vendor => vendor_amount' do
      entry.payload["propertyName"] = "invoice_from_vendor"
      expect(entry.attribute_name).to eq(:vendor_amount)
    end

    it 'invoice_notes => description' do
      entry.payload["propertyName"] = "invoice_notes"
      expect(entry.attribute_name).to eq(:description)
    end

    it 'vendor_name => vendor' do
      entry.payload["propertyName"] = "vendor_name"
      expect(entry.attribute_name).to eq(:vendor)
    end
  end

  describe '#attribute_value' do
    it 'amount => Money' do
      entry.payload["propertyName"] = "amount"
      entry.payload["propertyValue"] = "100"
      expect(entry.attribute_value).to eq("10000")
    end

    it 'closedate => Time' do
      entry.payload["propertyName"] = "closedate"
      entry.payload["propertyValue"] = "1654715463090"
      expect(entry.attribute_value).to eq(Time.at(1654715463090/1000))
    end

    it 'closed_lost_reason => String' do
      entry.payload["propertyName"] = "closed_lost_reason"
      entry.payload["propertyValue"] = "closed_lost_reason"
      expect(entry.attribute_value).to eq("closed_lost_reason")
    end

    it 'closed_won_reason => String' do
      entry.payload["propertyName"] = "closed_won_reason"
      entry.payload["propertyValue"] = "closed_won_reason"
      expect(entry.attribute_value).to eq("closed_won_reason")
    end

    it 'createdate => Time' do
      entry.payload["propertyName"] = "createdate"
      entry.payload["propertyValue"] = "1654715463090"
      expect(entry.attribute_value).to eq(Time.at(1654715463090/1000))
    end

    it 'date_estimate_sent => Time' do
      entry.payload["propertyName"] = "date_estimate_sent"
      entry.payload["propertyValue"] = "1654715463090"
      expect(entry.attribute_value).to eq(Time.at(1654715463090/1000))
    end

    it 'dealname => String' do
      entry.payload["propertyName"] = "dealname"
      entry.payload["propertyValue"] = "dealname"
      expect(entry.attribute_value).to eq("dealname")
    end

    it 'dealstage => WorkOrderStatus' do
      entry.payload["propertyName"] = "dealstage"
      entry.payload["propertyValue"] = "15611951"
      expect(entry.attribute_value).to eq(WorkOrderStatus.find_by(slug: "work_order_initiated"))
    end

    it 'dealtype => nil' do
      entry.payload["propertyName"] = "dealtype"
      entry.payload["propertyValue"] = "dealtype"
      expect(entry.attribute_value).to be_nil
    end

    it 'description => String' do
      entry.payload["propertyName"] = "description"
      entry.payload["propertyValue"] = "description"
      expect(entry.attribute_value).to eq("description")
    end

    it 'estimate_approved => Bool' do
      entry.payload["propertyName"] = "estimate_approved"
      entry.payload["propertyValue"] = "Yes"
      expect(entry.attribute_value).to be_truthy
    end

    it 'estimate___for_homeowner => Money' do
      entry.payload["propertyName"] = "estimate___for_homeowner"
      entry.payload["propertyValue"] = "100"
      expect(entry.attribute_value).to eq("10000")
    end

    it 'estimate___from_vendor => Money' do
      entry.payload["propertyName"] = "estimate___from_vendor"
      entry.payload["propertyValue"] = "100"
      expect(entry.attribute_value).to eq("10000")
    end

    it 'hs_lastmodifieddate => Time' do
      entry.payload["propertyName"] = "hs_lastmodifieddate"
      entry.payload["propertyValue"] = "1654715463090"
      expect(entry.attribute_value).to eq(Time.at(1654715463090/1000))
    end

    it 'invoice_for_homeowner => Money' do
      entry.payload["propertyName"] = "invoice_for_homeowner"
      entry.payload["propertyValue"] = "100"
      expect(entry.attribute_value).to eq("10000")
    end

    it 'invoice_from_vendor => Money' do
      entry.payload["propertyName"] = "invoice_from_vendor"
      entry.payload["propertyValue"] = "100"
      expect(entry.attribute_value).to eq("10000")
    end

    it 'invoice_notes => String' do
      entry.payload["propertyName"] = "invoice_notes"
      entry.payload["propertyValue"] = "invoice_notes"
      expect(entry.attribute_value).to eq("invoice_notes")
    end

    it 'vendor_name => String' do
      entry.payload["propertyName"] = "vendor_name"
      entry.payload["propertyValue"] = "vendor_name"
      expect(entry.attribute_value).to eq("vendor_name")
    end
  end

  describe '#[]' do
    it 'allows selecting payload params by key' do
      expect(entry['subscriptionType']).to eq(payload['subscriptionType'])
    end
  end
end
