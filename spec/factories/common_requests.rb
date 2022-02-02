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
FactoryBot.define do
  factory :common_request do
    caption { "Request Plumbing Service" }
    img_uri { "marian-florinel-condruz-C-oYJoIfgCs-unsplash.jpg" }
    default_hn_chat_message { "" }
  end
end
