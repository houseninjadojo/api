# == Schema Information
#
# Table name: invoices
#
#  id                   :uuid             not null, primary key
#  access_token         :string
#  description          :string
#  finalized_at         :datetime
#  payment_attempted_at :datetime
#  period_end           :datetime
#  period_start         :datetime
#  status               :string
#  stripe_object        :jsonb
#  total                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  promo_code_id        :uuid
#  stripe_id            :string
#  subscription_id      :uuid
#  user_id              :uuid
#  work_order_id        :uuid
#
# Indexes
#
#  index_invoices_on_access_token     (access_token) UNIQUE
#  index_invoices_on_promo_code_id    (promo_code_id)
#  index_invoices_on_status           (status)
#  index_invoices_on_stripe_id        (stripe_id) UNIQUE
#  index_invoices_on_subscription_id  (subscription_id)
#  index_invoices_on_user_id          (user_id)
#  index_invoices_on_work_order_id    (work_order_id)
#
# Foreign Keys
#
#  fk_rails_...  (promo_code_id => promo_codes.id)
#  fk_rails_...  (subscription_id => subscriptions.id)
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (work_order_id => work_orders.id) ON DELETE => cascade
#
FactoryBot.define do
  factory :invoice do
    description { Faker::Lorem.sentence(word_count: 4) }
    status { "paid" }
    total { "29.00" }
    period_start { Faker::Date.backward(days: 45) }
    period_end { Faker::Date.backward(days: 15) }

    stripe_id { Faker::Alphanumeric.alphanumeric(number: 20) }

    trait :finalized do
      finalized_at { Faker::Date.backward(days: 2) }
    end

    trait :payment_attempted do
      payment_attempted_at { Faker::Date.backward(days: 1) }
    end

    trait :with_payment do
      user
      payment_attempted_at { Faker::Date.backward(days: 1) }
      after(:create) do |invoice|
        payment_method = create(:payment_method, :with_stripe_token, user: invoice.user)
        create(:payment, invoice: invoice, payment_method: payment_method)
      end
    end

    trait :with_user do
      user
    end

    trait :with_relationships do
      user
      promo_code
      subscription
    end
  end
end
