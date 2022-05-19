# == Schema Information
#
# Table name: deep_links
#
#  id            :uuid             not null, primary key
#  campaign      :string
#  canonical_url :string
#  data          :jsonb
#  deeplink_path :string
#  expired_at    :datetime
#  feature       :string
#  linkable_type :string
#  path          :string
#  stage         :string
#  tags          :string           default([]), is an Array
#  url           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  linkable_id   :uuid
#
# Indexes
#
#  index_deep_links_on_linkable  (linkable_type,linkable_id)
#
FactoryBot.define do
  factory :deep_link do
    url { "MyString" }
    feature { "MyString" }
    campaign { "MyString" }
    stage { "MyString" }
    tags { "MyString" }
    data { "" }
  end
end
