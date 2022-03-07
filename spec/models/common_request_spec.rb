# == Schema Information
#
# Table name: common_requests
#
#  id                      :uuid             not null, primary key
#  caption                 :string
#  img_uri                 :string
#  default_hn_chat_message :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  order_index             :integer
#
# Indexes
#
#  index_common_requests_on_order_index  (order_index) UNIQUE
#
require 'rails_helper'

RSpec.describe CommonRequest, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
