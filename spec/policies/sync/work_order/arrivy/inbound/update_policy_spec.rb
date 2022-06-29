require "rails_helper"

RSpec.describe Sync::WorkOrder::Arrivy::Inbound::UpdatePolicy, type: :policy do
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
      "EXCEPTION"=>nil,
      "EVENT_TIME"=>"2022-06-28T17:16:22",
      "TITLE"=>"Gutter cleaning added",
      "OBJECT_END_DATE"=>"2022-06-29T10:30:00-07:00",
      "REPORTER_NAME"=>"Rachael",
      "IS_TRANSIENT_STATUS"=>false,
      "RESPONSE_FROM_CUSTOMER"=>false,
      "OBJECT_ID"=>5892463768371200,
      "EVENT_SUB_TYPE"=>nil,
      "EVENT_TYPE"=>"TASK_CREATED",
      "OBJECT_FIELDS"=>
        { "BOOKING_METADATA"=>{ "BOOKED_BY"=>nil, "BOOKING_ID"=>nil, "IS_BOOKING"=>false, "BOOKING_SLOT_ID"=>nil },
        "ITEMS"=>nil,
        "LIVE_TRACK_URL"=>"https://app.arrivy.com/lt/WbJOr5G ",
        "ENABLE_TIME_WINDOW_DISPLAY"=>false,
        "DURATION"=>60,
        "LINKED_INTERNAL_ID"=>6384020846018560,
        "END_DATETIME"=>"2022-06-29T10:30:00-07:00",
        "ENTITY_IDS"=>[],
        "TIME_WINDOW_START"=>0,
        "LIVE_TRACK_BUSINESS_URL"=>"https://app.arrivy.com/lt/qj0zAB0 ",
        "LINKED_EXTERNAL_ID"=>"9267154287" },
      "EVENT_TIMESTAMP"=>1656436582,
      "OBJECT_DURATION"=>60,
      "OBJECT_EXTERNAL_ID"=>"9267154287",
      "EVENT_ID"=>6063059600932864,
      "ITEMS"=>nil,
      "OBJECT_TYPE"=>"TASK",
      "OBJECT_TEMPLATE_ID"=>5989917552803840,
      "REPORTER_ID"=>5702289902010368,
      "HAS_ATTACHMENT"=>false,
      "OBJECT_DATE"=>"2022-06-29T09:30:00-07:00",
      "OBJECT_GROUP_ID"=>nil,
      "MESSAGE"=>"New Task Gutter cleaning added for 06/29 09:30 AM by Rachael.",
      "OBJECT_CUSTOMER_ID"=>6285274514718720,
      "EXTRA_FIELDS"=>{ "task_color"=>"#0693E3", "visible_to_customer"=>false, "Job Type"=>"Gutters R Us", "Vendor name"=>"Gutters R Us", "Homeowner Name"=>"Sloane  Burkholder", "notes"=>"New Task created." }
    }
  }
  let(:webhook_event) {
    create(:webhook_event,
      service: 'arrivy',
      payload: payload
    )
  }
  let(:policy) { described_class.new(Arrivy::Event.new(payload), webhook_event: webhook_event) }

  describe_rule :can_sync? do
    it "returns true if all conditions true" do
      expect(policy).to receive(:webhook_is_unprocessed?).and_return(true)
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:has_work_order?).and_return(true)
      expect(policy).to receive(:is_valid_task_status?).and_return(true)
      expect(policy).to receive(:has_dates_and_times?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions false" do
      expect(policy).to receive(:webhook_is_unprocessed?).and_return(true)
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:has_work_order?).and_return(true)
      expect(policy).to receive(:is_valid_task_status?).and_return(true)
      expect(policy).to receive(:has_dates_and_times?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    it "returns true if external id present" do
      payload["OBJECT_EXTERNAL_ID"] = '1234'
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if external id not present" do
      payload["OBJECT_EXTERNAL_ID"] = nil
      payload["OBJECT_FIELDS"]["LINKED_EXTERNAL_ID"] = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :has_work_order? do
    it "returns true if external id present" do
      expect(WorkOrder).to receive(:find_by).with(hubspot_id: '1234').and_return(work_order)
      payload["OBJECT_EXTERNAL_ID"] = '1234'
      expect(policy.has_work_order?).to be_truthy
    end

    it "returns false if external id not present" do
      expect(WorkOrder).to receive(:find_by).with(hubspot_id: '1234').and_return(nil)
      payload["OBJECT_EXTERNAL_ID"] = '1234'
      expect(policy.has_work_order?).to be_falsey
    end
  end

  describe_rule :is_valid_task_status? do
    it "returns true if task_status valid" do
      payload["EVENT_TYPE"] = 'TASK_CREATED'
      expect(policy.is_valid_task_status?).to be_truthy
    end

    it "returns false if task_status not valid" do
      payload["EVENT_TYPE"] = 'asdfasdf'
      expect(policy.is_valid_task_status?).to be_falsey
    end
  end

  describe_rule :has_dates_and_times? do
    it "returns true if dates to update" do
      payload["OBJECT_END_DATE"] = "2022-06-29T10:30:00-07:00"
      expect(policy.has_dates_and_times?).to be_truthy
    end

    it "returns false no dates to update" do
      payload["OBJECT_END_DATE"] = nil
      payload["OBJECT_DATE"] = nil
      payload["OBJECT_FIELDS"]["END_DATETIME"] = nil
      expect(policy.has_dates_and_times?).to be_falsey
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
end
