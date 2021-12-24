# == Schema Information
#
# Table name: properties
#
#  id              :uuid             not null, primary key
#  user_id         :uuid
#  lot_size        :integer
#  home_size       :integer
#  garage_size     :integer
#  home_age        :integer
#  estimated_value :string
#  bedrooms        :integer
#  bathrooms       :integer
#  pools           :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_properties_on_user_id  (user_id)
#
class PropertyResource < ApplicationResource
  self.model = Property
  self.type = :properties

  primary_endpoint 'properties', [:index, :show, :create, :update, :destroy]

  belongs_to :user
  has_one    :address

  attribute :id,      :uuid
  attribute :user_id, :uuid

  attribute :lot_size,        :integer
  attribute :home_size,       :integer
  attribute :garage_size,     :integer
  attribute :home_age,        :integer
  attribute :estimated_value, :string
  attribute :bedrooms,        :integer
  attribute :bathrooms,       :integer
  attribute :pools,           :integer

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
