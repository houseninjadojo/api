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
class PaymentMethodResource < ApplicationResource
  # self.model = CreditCard
  self.type = 'payment-methods'

  self.polymorphic = [
    'CreditCardResource',
  ]
  belongs_to :user

  primary_endpoint 'payment-methods', [:index, :show, :create, :update]

  attribute :id, :uuid

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
