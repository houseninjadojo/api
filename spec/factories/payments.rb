# == Schema Information
#
# Table name: payments
#
#  id                   :uuid             not null, primary key
#  invoice_id           :uuid
#  user_id              :uuid
#  payment_method_id    :uuid
#  amount               :string
#  description          :string
#  statement_descriptor :string
#  status               :string
#  refunded             :boolean          default(FALSE), not null
#  paid                 :boolean          default(FALSE), not null
#  stripe_id            :string
#  stripe_object        :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_payments_on_invoice_id         (invoice_id)
#  index_payments_on_payment_method_id  (payment_method_id)
#  index_payments_on_status             (status)
#  index_payments_on_stripe_id          (stripe_id) UNIQUE
#  index_payments_on_user_id            (user_id)
#
FactoryBot.define do
  factory :payment do
    amount { "29.00" }
    description { Faker::Lorem.sentence(word_count: 4) }
    statement_descriptor { "HOUSE NINJA, INC." }
    status { "succeeded" }
    refunded { false }
    paid { true }

    trait :with_relationships do
      invoice
      user
      payment_method
    end
  end
end
