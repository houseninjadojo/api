# == Schema Information
#
# Table name: estimates
#
#  id                      :uuid             not null, primary key
#  approved_at             :datetime
#  deleted_at              :datetime
#  description             :text
#  homeowner_amount        :string
#  homeowner_amount_actual :string
#  scheduled_at            :datetime
#  scheduled_window_end    :datetime
#  scheduled_window_start  :datetime
#  shared_at               :datetime
#  vendor_amount           :string
#  vendor_category         :string
#  vendor_name             :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  work_order_id           :uuid             not null
#
# Indexes
#
#  index_estimates_on_approved_at    (approved_at)
#  index_estimates_on_shared_at      (shared_at)
#  index_estimates_on_work_order_id  (work_order_id)
#
# Foreign Keys
#
#  fk_rails_...  (work_order_id => work_orders.id)
#
FactoryBot.define do
  factory :estimate do
    work_order

    description { Faker::Lorem.sentence(word_count: 4) }

    scheduled_window_start { Faker::Time.between_dates(from: Date.today + 5.days, to: Date.today + 15.days, period: :all) }
    scheduled_window_end { scheduled_window_start + 2.hours }

    vendor_category { Faker::Construction.trade }
    vendor_name { Faker::Company.name }

    homeowner_amount { Faker::Number.between(from: 10000, to: 1000000) }
  end
end
