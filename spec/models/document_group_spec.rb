# == Schema Information
#
# Table name: document_groups
#
#  id          :uuid             not null, primary key
#  user_id     :uuid             not null
#  name        :string           not null
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_document_groups_on_user_id  (user_id)
#
require 'rails_helper'

RSpec.describe DocumentGroup, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
