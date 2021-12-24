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

require 'rails_helper'

RSpec.describe Address, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
