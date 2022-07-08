class Arrivy::Task
  attr_accessor :id
  attr_accessor :title, :start_datetime, :end_datetime, :enable_expected_date_range, :expected_start_datetime,
                :expected_end_datetime, :enable_time_window_display, :task_without_time, :time_window_start,
                :enable_time_window_display, :duration, :unscheduled, :details,

title
start_datetime
end_datetime
enable_time_window_display	boolean
time_window_start	integer
unscheduled	boolean
details	string
customer_first_name	string
customer_last_name	string
customer_email	string
customer_company_name	string
customer_address_line_1	string
customer_city	string
customer_state	string
customer_country	string
customer_zipcode	string
customer_mobile_number	string
customer_phone	string
customer_id	integer
customer_exact_location	{...}
notifications	{...}
source	string
external_url	string
group_id	integer
template	integer

  def initialize(params = {})
    params.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def self.all
    response = Arrivy::Request.get("customers")
    if response.code == 200
      response_body = JSON.parse(response.body)
      return response_body.map { |customer| Arrivy::Customer.new(customer) }
    end
    return false
  end

  def self.find(id)
    response = Arrivy::Request.get("customers/#{id}")
    if response.code == 200
      response_body = JSON.parse(response.body)
      return Arrivy::Customer.new(response_body)
    end
    return nil
  end

  def create
    response = Arrivy::Request.post("customers", params)
    if response.code == 200
      response_body = JSON.parse(response.body)
      @id = response_body["id"]
      return Arrivy::Customer.new(response_body)
    end
    return false
  end

  def update
    response = Arrivy::Request.put("customers/#{customer_id}", params)
    if response.code == 200
      response_body = JSON.parse(response.body)
      return Arrivy::Customer.new(response_body)
    end
    return false
  end
  alias :save :update

  def as_json
    params
  end

  def customer_id
    id
  end

  def id
    @id&.to_s
  end

  def phone
    Phonelib.parse(@phone).e164
  end

  def mobile_number
    Phonelib.parse(@mobile_number).e164
  end

  private

  def params
    {
      first_name: first_name,
      last_name: last_name,
      company_name: company_name,
      notes: notes,
      email: email,
      phone: phone,
      mobile_number: mobile_number,
      address_line_1: address_line_1,
      address_line_2: address_line_2,
      city: city,
      state: state,
      zipcode: zipcode,
      exact_location: exact_location,
      complete_address: complete_address,
      additional_addresses: additional_addresses,
      extra_fields: extra_fields,
      notifications: notifications,
      external_id: external_id,
      company_id: company_id
    }.compact
  end
end
