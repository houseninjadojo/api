# == Schema Information
#
# Table name: work_order_statuses
#
#  id                  :uuid             not null, primary key
#  name                :string
#  slug                :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  hubspot_id          :string
#  hubspot_pipeline_id :string
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
