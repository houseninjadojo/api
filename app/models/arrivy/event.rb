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

    ALL = [
      TASK_CREATED,
      TASK_DELETED,
      TASK_STATUS,
      CREW_ASSIGNED,
      CREW_REMOVED,
      EQUIPMENT_ASSIGNED,
      EQUIPMENT_REMOVED,
      TASK_RATING,
      TASK_RESCHEDULED,
      TASK_GROUP_CHANGED,
      ARRIVING,
      LATE,
      NOSHOW,
    ]
  end

  class Object
    attr_reader :end_datetime, :duration, :linked_internal_id, :linked_external_id,
                :response_from_customer, :has_attachment, :items, :rating_type,
                :time_window_start

    def initialize(object)
      @end_datetime = Time.parse(object["END_DATETIME"]) if object["END_DATETIME"].present?
      @duration = object["DURATION"]
      @linked_internal_id = object["LINKED_INTERNAL_ID"]
      @linked_external_id = object["LINKED_EXTERNAL_ID"]
      @response_from_customer = object["RESPONSE_FROM_CUSTOMER"]
      @has_attachment = object["HAS_ATTACHMENT"]
      @items = object["ITEMS"]
      @rating_type = object["RATING_TYPE"]
      @time_window_start = object["TIME_WINDOW_START"]
    end
  end

  attr_reader :title, :message, :event_id, :event_type, :event_sub_type, :event_time,
              :reporter_id, :reporter_name, :object_id, :object_type, :object_date,
              :object_group_id, :object_customer_id, :object_external_id,
              :is_transient_status, :exception, :object_fields, :extra_fields,
              :object_end_date

  def initialize(event)
    @title = event["TITLE"]
    @message = event["MESSAGE"]
    @event_id = event["EVENT_ID"]
    @event_type = event["EVENT_TYPE"]
    @event_sub_type = event["EVENT_SUB_TYPE"]
    @event_time = Time.parse(event["EVENT_TIME"]) if event["EVENT_TIME"].present?
    @reporter_id = event["REPORTER_ID"]
    @reporter_name = event["REPORTER_NAME"]
    @object_id = event["OBJECT_ID"]
    @object_type = event["OBJECT_TYPE"]
    @object_date = Time.parse(event["OBJECT_DATE"]) if event["OBJECT_DATE"].present?
    @object_end_date = Time.parse(event["OBJECT_END_DATE"]) if event["OBJECT_END_DATE"].present?
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
    object_external_id || object_fields.linked_external_id
  end

  def arrivy_id
    object_id || object_fields.linked_internal_id
  end

  def starting_at
    object_date
  end
  alias :scheduled_window_start :starting_at

  def ending_at
    object_end_date || object_fields.end_datetime
  end
  alias :scheduled_window_end :ending_at

  def scheduled_date
    starting_at&.strftime("%m/%d/%Y")
  end

  def scheduled_time
    start_time = starting_at&.strftime("%I:%M %p")
    if scheduled_time_window > 0
      start_time_end = (starting_at + scheduled_time_window.minutes)
      "#{start_time} - #{start_time_end.strftime("%I:%M %p")}"
    else
      start_time
    end
  end

  def duration
    object_duration || object_fields.duration || 0
  end

  def scheduled_time_window
    object_fields.time_window_start || 0
  end
end
