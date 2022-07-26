# == Schema Information
#
# Table name: properties
#
#  id              :uuid             not null, primary key
#  bathrooms       :float
#  bedrooms        :float
#  city            :string
#  default         :boolean
#  estimated_value :string
#  garage_size     :float
#  home_size       :float
#  lot_size        :float
#  pools           :float
#  selected        :boolean
#  state           :string
#  street_address1 :string
#  street_address2 :string
#  year_built      :integer
#  zipcode         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  service_area_id :uuid
#  user_id         :uuid
#
# Indexes
#
#  index_properties_on_city                  (city)
#  index_properties_on_service_area_id       (service_area_id)
#  index_properties_on_state                 (state)
#  index_properties_on_user_id               (user_id)
#  index_properties_on_user_id_and_default   (user_id,default) UNIQUE
#  index_properties_on_user_id_and_selected  (user_id,selected)
#  index_properties_on_zipcode               (zipcode)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class PropertyResource < ApplicationResource
  self.model = Property
  self.type = :properties

  primary_endpoint 'properties', [:index, :show, :create, :update, :destroy]

  has_many :documents
  has_many :work_orders do
    params do |hash, work_orders|
      work_orders.available.has_status
    end
  end
  belongs_to :service_area
  belongs_to :user

  attribute :id, :uuid

  attribute :user_id,         :uuid, only: [:filterable]
  attribute :service_area_id, :uuid, only: [:filterable]

  attribute :street_address1, :string
  attribute :street_address2, :string
  attribute :city,            :string
  attribute :state,           :string
  attribute :zipcode,         :string

  attribute :lot_size,        :float,   sortable: false
  attribute :home_size,       :float,   sortable: false
  attribute :garage_size,     :float,   sortable: false
  attribute :year_built,      :integer, sortable: false
  attribute :estimated_value, :string,  sortable: false
  attribute :bedrooms,        :float,   sortable: false
  attribute :bathrooms,       :float,   sortable: false
  attribute :pools,           :float,   sortable: false

  attribute :default,  :boolean
  attribute :selected, :boolean

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
