class Arrivy::Task
  attr_accessor :id
  attr_accessor :title, :start_datetime, :end_datetime, :enable_expected_date_range, :expected_start_datetime,
                :expected_end_datetime, :enable_time_window_display, :task_without_time, :time_window_start,
                :duration, :extra_fields, :details, :customer_first_name, :customer_last_name, :customer_email,
                :customer_company_name, :customer_address_line_1, :customer_address_line_2, :customer_city,
                :customer_state, :customer_country, :customer_zipcode, :customer_exact_location, :customer_address,
                :customer_mobile_number, :customer_phone, :customer_notes, :customer_id, :notifications, :source,
                :source_id, :external_url, :external_id, :group_id, :template, :additional_addresses, :entity_ids,
                :resource_ids, :skill_ids, :items, :use_assignee_color, :forms, :company_id

  def initialize(params = {})
    params.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def self.all
    response = Arrivy::Request.get("tasks")
    if response.code == 200
      response_body = JSON.parse(response.body)
      return response_body.map { |task| Arrivy::Task.new(task) }
    end
    return false
  end

  def self.find(id)
    response = Arrivy::Request.get("tasks/#{id}")
    if response.code == 200
      response_body = JSON.parse(response.body)
      return Arrivy::Task.new(response_body)
    end
    return nil
  end

  def create
    response = Arrivy::Request.post("tasks", params)
    if response.code == 200
      response_body = JSON.parse(response.body)
      @id = response_body["id"]
      return Arrivy::Task.new(response_body)
    end
    return false
  end

  def update
    response = Arrivy::Request.put("tasks/#{task_id}", params)
    if response.code == 200
      response_body = JSON.parse(response.body)
      return Arrivy::Task.new(response_body)
    end
    return false
  end
  alias :save :update

  def as_json
    params
  end

  def task_id
    id
  end

  def id
    @id&.to_s
  end

  private

  def params
    {
      title: title,
      start_datetime: start_datetime,
      end_datetime: end_datetime,
      enable_expected_date_range: enable_expected_date_range,
      expected_start_datetime: expected_start_datetime,
      expected_end_datetime: expected_end_datetime,
      enable_time_window_display: enable_time_window_display,
      task_without_time: task_without_time,
      time_window_start: time_window_start,
      duration: duration,
      extra_fields: extra_fields,
      details: details,
      customer_first_name: customer_first_name,
      customer_last_name: customer_last_name,
      customer_email: customer_email,
      customer_company_name: customer_company_name,
      customer_address_line_1: customer_address_line_1,
      customer_address_line_2: customer_address_line_2,
      customer_city: customer_city,
      customer_state: customer_state,
      customer_country: customer_country,
      customer_zipcode: customer_zipcode,
      customer_exact_location: customer_exact_location,
      customer_address: customer_address,
      customer_mobile_number: customer_mobile_number,
      customer_phone: customer_phone,
      customer_notes: customer_notes,
      customer_id: customer_id,
      notifications: notifications,
      source: source,
      source_id: source_id,
      external_url: external_url,
      external_id: external_id,
      group_id: group_id,
      template: template,
      additional_addresses: additional_addresses,
      entity_ids: entity_ids,
      resource_ids: resource_ids,
      skill_ids: skill_ids,
      items: items,
      use_assignee_color: use_assignee_color,
      forms: forms,
      company_id: company_id,
    }.compact
  end
end
