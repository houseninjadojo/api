# == Schema Information
#
# Table name: work_orders
#
#  id             :uuid             not null, primary key
#  property_id    :uuid             not null
#  status         :string
#  description    :string
#  vendor         :string
#  scheduled_date :string
#  scheduled_time :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_work_orders_on_property_id  (property_id)
#
FactoryBot.define do
  factory :work_order do
    property
    status { "open" }
    description { Faker::Lorem.sentences(number: 1) }
    vendor { Faker::Company.name }
    scheduled_date { "11/11/21" }
    scheduled_time { "10:00 AM - 2:00 PM" }
  end
end
