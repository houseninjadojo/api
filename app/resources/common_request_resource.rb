# == Schema Information
#
# Table name: common_requests
#
#  id                      :uuid             not null, primary key
#  caption                 :string
#  default_hn_chat_message :string
#  img_uri                 :string
#  order_index             :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_common_requests_on_order_index  (order_index) UNIQUE
#
class CommonRequestResource < ApplicationResource
  self.model = CommonRequest
  self.type = 'common-requests'

  primary_endpoint 'common-requests', [:index, :show]

  attribute :id, :uuid

  attribute :caption, :string
  attribute :img_uri, :string
  attribute :default_hn_chat_message, :string

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
