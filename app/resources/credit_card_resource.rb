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
#  last_four    :string
#
# Indexes
#
#  index_payment_methods_on_stripe_token  (stripe_token) UNIQUE
#  index_payment_methods_on_user_id       (user_id)
#
class CreditCardResource < PaymentMethodResource
  # self.model = PaymentMethod
  self.type = 'credit-cards'

  attribute :brand,       :string, sortable: false
  attribute :country,     :string, sortable: false
  attribute :cvv,         :string, sortable: false, readable: false
  attribute :exp_month,   :string
  attribute :exp_year,    :string
  attribute :card_number, :string, readable: false
  attribute :zipcode,     :string
  attribute :last_four,   :string, except: [:sortable]
end
