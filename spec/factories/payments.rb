# == Schema Information
#
# Table name: payments
#
#  id                   :uuid             not null, primary key
#  amount               :string
#  description          :string
#  originator           :string
#  paid                 :boolean          default(FALSE), not null
#  purpose              :string
#  refunded             :boolean          default(FALSE), not null
#  statement_descriptor :string
#  status               :string
#  stripe_object        :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  invoice_id           :uuid
#  payment_method_id    :uuid
#  stripe_id            :string
#  user_id              :uuid
#
# Indexes
#
#  index_payments_on_invoice_id         (invoice_id)
#  index_payments_on_payment_method_id  (payment_method_id)
#  index_payments_on_status             (status)
#  index_payments_on_stripe_id          (stripe_id) UNIQUE
#  index_payments_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (invoice_id => invoices.id)
#  fk_rails_...  (payment_method_id => payment_methods.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :payment do
    amount { "29.00" }
    description { Faker::Lorem.sentence(word_count: 4) }
    statement_descriptor { "HOUSE NINJA, INC." }
    status { "succeeded" }
    refunded { false }
    paid { true }

    trait :with_user do
      user
    end

    trait :with_payment_method do
      payment_method
    end

    trait :with_invoice do
      invoice
    end

    trait :with_relationships do
      invoice
      user
      payment_method
    end
  end
end
