class Arrivy::Customer
  attr_accessor :id
  attr_accessor :first_name, :last_name, :company_name, :notes, :email, :phone, :mobile_number,
                :address_line_1, :address_line_2, :city, :state, :zipcode, :exact_location,
                :complete_address, :additional_addresses, :extra_fields, :notifications, :external_id,
                :company_id

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
