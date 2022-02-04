# == Schema Information
#
# Table name: properties
#
#  id              :uuid             not null, primary key
#  user_id         :uuid
#  lot_size        :float
#  home_size       :float
#  garage_size     :float
#  year_built      :integer
#  estimated_value :string
#  bedrooms        :float
#  bathrooms       :float
#  pools           :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  service_area_id :uuid
#  default         :boolean
#  selected        :boolean
#
# Indexes
#
#  index_properties_on_service_area_id       (service_area_id)
#  index_properties_on_user_id               (user_id)
#  index_properties_on_user_id_and_default   (user_id,default) UNIQUE
#  index_properties_on_user_id_and_selected  (user_id,selected)
#

class PropertyResource < ApplicationResource
  self.model = Property
  self.type = :properties

  primary_endpoint 'properties', [:index, :show, :create, :update, :destroy]

  has_many :work_orders
  belongs_to :service_area
  belongs_to :user
  polymorphic_has_one :address, as: :addressible

  attribute :id, :uuid

  attribute :user_id, :uuid, only: [:filterable]
  attribute :service_area_id, :uuid, only: [:filterable]

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
