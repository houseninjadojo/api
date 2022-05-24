class Arrivy::Event
  module TYPES
    TASK_CREATED = "TASK_CREATED"
	  TASK_DELETED = "TASK_DELETED"
	  TASK_STATUS = "TASK_STATUS"
	  CREW_ASSIGNED = "CREW_ASSIGNED"
	  CREW_REMOVED = "CREW_REMOVED"
	  EQUIPMENT_ASSIGNED = "EQUIPMENT_ASSIGNED"
	  EQUIPMENT_REMOVED = "EQUIPMENT_REMOVED"
	  TASK_RATING = "TASK_RATING"
	  TASK_RESCHEDULED = "TASK_RESCHEDULED"
	  TASK_GROUP_CHANGED = "TASK_GROUP_CHANGED"
	  ARRIVING = "ARRIVING"
	  LATE = "LATE"
	  NOSHOW = "NOSHOW"
  end

  class Object
    attr_reader :end_datetime, :duration, :linked_internal_id, :linked_external_id,
                :response_from_customer, :has_attachment, :items, :rating_type

    def initialize(object)
      @end_datetime = Time.parse(object["END_DATETIME"])
      @duration = object["DURATION"]
      @linked_internal_id = object["LINKED_INTERNAL_ID"]
      @linked_external_id = object["LINKED_EXTERNAL_ID"]
      @response_from_customer = object["RESPONSE_FROM_CUSTOMER"]
      @has_attachment = object["HAS_ATTACHMENT"]
      @items = object["ITEMS"]
      @rating_type = object["RATING_TYPE"]
    end
  end

  attr_reader :title, :message, :event_id, :event_type, :event_sub_type, :event_time,
              :reporter_id, :reporter_name, :object_id, :object_type, :object_date,
              :object_group_id, :object_customer_id, :object_external_id,
              :is_transient_status, :exception, :object_fields, :extra_fields

  def initialize(event)
    @title = event["TITLE"]
    @message = event["MESSAGE"]
    @event_id = event["EVENT_ID"]
    @event_type = event["EVENT_TYPE"]
    @event_sub_type = event["EVENT_SUB_TYPE"]
    @event_time = Time.parse(event["EVENT_TIME"])
    @reporter_id = event["REPORTER_ID"]
    @reporter_name = event["REPORTER_NAME"]
    @object_id = event["OBJECT_ID"]
    @object_type = event["OBJECT_TYPE"]
    @object_date = Time.parse(event["OBJECT_DATE"])
    @object_external_id = event["OBJECT_EXTERNAL_ID"]
    @object_group_id = event["OBJECT_GROUP_ID"]
    @object_customer_id = event["OBJECT_CUSTOMER_ID"]
    @is_transient_status = event["IS_TRANSIENT_STATUS"]
    @exception = event["EXCEPTION"]
    @object_fields = Arrivy::Event::Object.new(event["OBJECT_FIELDS"])
    @extra_fields = event["EXTRA_FIELDS"]
  end

  def self.create(event)
    new(event)
  end

  def hubspot_id
    object_external_id
  end
end
