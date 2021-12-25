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

require 'rails_helper'

RSpec.describe Property, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
