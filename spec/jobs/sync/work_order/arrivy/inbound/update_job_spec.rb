require 'rails_helper'

RSpec.describe Sync::WorkOrder::Arrivy::Inbound::UpdateJob, type: :job do
  let(:work_order) {
    create(:work_order,
      hubspot_id: '1234',
      status: WorkOrderStatus.find_by(slug: 'closed'),
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
      service: 'hubspot',
      payload: payload,
    )
  }
  let(:job) { Sync::WorkOrder::Arrivy::Inbound::UpdateJob }

  before do
    allow(WorkOrder).to(receive(:find_by).and_return(work_order))
  end

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      # entry = Hubspot::Webhook::Entry.new(webhook_event, webhook_entry)
      expect(work_order).not_to receive(:update!)
      job.perform_now(webhook_event)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      event = Arrivy::Event.new(payload)
      expect(work_order).to receive(:update!).with(
        arrivy_id: 5892463768371200,
        scheduled_date: event.scheduled_date,
        scheduled_time: event.scheduled_time,
        scheduled_window_end: event.scheduled_window_end,
        scheduled_window_start: event.scheduled_window_start,
      )
      expect(webhook_event).to receive(:update!)
      job.perform_now(webhook_event)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event).policy).to be_a(Sync::WorkOrder::Arrivy::Inbound::UpdatePolicy)
    end
  end

  describe "#params" do
    it "returns params for WorkOrder" do
      allow_any_instance_of(job).to(receive(:webhook_event).and_return(webhook_event))
      event = Arrivy::Event.new(payload)
      expect(job.new(webhook_event).params).to eq({
        arrivy_id: 5892463768371200,
        scheduled_date: event.scheduled_date,
        scheduled_time: event.scheduled_time,
        scheduled_window_end: event.scheduled_window_end,
        scheduled_window_start: event.scheduled_window_start,
      })
    end
  end
end
