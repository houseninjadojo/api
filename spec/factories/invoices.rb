# == Schema Information
#
# Table name: invoices
#
#  id              :uuid             not null, primary key
#  promo_code_id   :uuid
#  subscription_id :uuid
#  user_id         :uuid
#  description     :string
#  status          :string
#  total           :string
#  period_start    :datetime
#  period_end      :datetime
#  stripe_id       :string
#  stripe_object   :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_invoices_on_promo_code_id    (promo_code_id)
#  index_invoices_on_status           (status)
#  index_invoices_on_stripe_id        (stripe_id) UNIQUE
#  index_invoices_on_subscription_id  (subscription_id)
#  index_invoices_on_user_id          (user_id)
#
FactoryBot.define do
  factory :invoice do
    description { Faker::Lorem.sentence(word_count: 4) }
    status { "paid" }
    total { "29.00" }
    period_start { Faker::Date.backward(days: 45) }
    period_end { Faker::Date.backward(days: 15) }
  end
end
