# == Schema Information
#
# Table name: payment_methods
#
#  id           :uuid             not null, primary key
#  type         :string
#  user_id      :uuid             not null
#  stripe_token :string
#  brand        :string
#  country      :string
#  cvv          :string
#  exp_month    :string
#  exp_year     :string
#  card_number  :string
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_payment_methods_on_stripe_token  (stripe_token) UNIQUE
#  index_payment_methods_on_user_id       (user_id)
#
FactoryBot.define do
  factory :credit_card, parent: :payment_method, class: 'CreditCard' do
    # user
    brand { [:mastercard, :visa].sample }
    country { "US" }
    cvv { "123" }
    exp_month { 1.year.from_now.strftime("%m") }
    exp_year { 1.year.from_now.strftime("%Y") }
    card_number { Faker::Finance.credit_card(brand) }
    zipcode { Faker::Address.zip_code }
  end
end
