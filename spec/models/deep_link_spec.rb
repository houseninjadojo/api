# == Schema Information
#
# Table name: deep_links
#
#  id            :uuid             not null, primary key
#  campaign      :string
#  canonical_url :string
#  data          :jsonb
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
require 'rails_helper'

RSpec.describe DeepLink, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
