# == Schema Information
#
# Table name: work_orders
#
#  id                      :uuid             not null, primary key
#  completed_at            :datetime
#  customer_approved_work  :boolean
#  deleted_at              :datetime
#  description             :string
#  homeowner_amount        :string
#  homeowner_amount_actual :string
#  hubspot_object          :jsonb
#  invoice_notes           :text
#  refund_amount           :string
#  refund_reason           :string
#  requested_at            :datetime
#  scheduled_date          :string
#  scheduled_time          :string
#  scheduled_window_end    :datetime
#  scheduled_window_start  :datetime
#  status                  :string
#  vendor                  :string
#  vendor_amount           :string
#  walkthrough_date        :datetime
#  walkthrough_time        :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  arrivy_id               :string
#  hubspot_id              :string
#  property_id             :uuid
#
# Indexes
#
#  index_work_orders_on_arrivy_id    (arrivy_id) UNIQUE
#  index_work_orders_on_deleted_at   (deleted_at)
#  index_work_orders_on_hubspot_id   (hubspot_id) UNIQUE
#  index_work_orders_on_property_id  (property_id)
#
# Foreign Keys
#
#  fk_rails_...  (property_id => properties.id)
#
FactoryBot.define do
  factory :work_order do
    property
    status { build(:work_order_status) }
    description { Faker::Lorem.sentences(number: 1) }
    vendor { Faker::Company.name }
    scheduled_date { "11/11/21" }
    scheduled_time { "10:00 AM - 2:00 PM" }
  end
end
