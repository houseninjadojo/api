# == Schema Information
#
# Table name: payment_methods
#
#  id           :uuid             not null, primary key
#  brand        :string
#  card_number  :string
#  country      :string
#  cvv          :string
#  exp_month    :string
#  exp_year     :string
#  last_four    :string
#  stripe_token :string
#  type         :string
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#
# Indexes
#
#  index_payment_methods_on_stripe_token  (stripe_token) UNIQUE
#  index_payment_methods_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
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
