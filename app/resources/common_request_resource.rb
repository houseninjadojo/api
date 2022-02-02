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
