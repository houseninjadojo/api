# == Schema Information
#
# Table name: addresses
#
#  id               :uuid             not null, primary key
#  addressible_type :string
#  addressible_id   :uuid
#  street1          :string
#  street2          :string
#  city             :string
#  zipcode          :string
#  state            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_addresses_on_addressible  (addressible_type,addressible_id)
#  index_addresses_on_city         (city)
#  index_addresses_on_state        (state)
#  index_addresses_on_zipcode      (zipcode)
#
class AddressResource < ApplicationResource
  self.model = Address
  self.type = :addresses

  primary_endpoint 'addresses', [:index, :show, :create, :update, :destroy]

  polymorphic_belongs_to :addressible do
    group_by(:addressible_type) do
      on(:Property)
    end
  end

  attribute :id, :uuid

  attribute :street1, :string, sortable: false
  attribute :street2, :string, sortable: false
  attribute :city,    :string
  attribute :zipcode, :string
  attribute :state,   :string

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
