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
FactoryBot.define do
  factory :document_group do
    user
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
  end
end
