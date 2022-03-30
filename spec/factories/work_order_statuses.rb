# == Schema Information
#
# Table name: work_order_statuses
#
#  id         :uuid             not null, primary key
#  slug       :string           not null
#  name       :string
#  hubspot_id :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_work_order_statuses_on_hubspot_id  (hubspot_id) UNIQUE
#  index_work_order_statuses_on_slug        (slug) UNIQUE
#
FactoryBot.define do
  factory :work_order_status, class: 'WorkOrderStatus' do
    slug { "work_request_received" }
    name { "Work Request Received" }
    hubspot_id { "123456" }
  end
end
