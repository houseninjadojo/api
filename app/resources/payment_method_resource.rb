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
class PaymentMethodResource < ApplicationResource
  # self.model = CreditCard
  self.type = 'payment-methods'

  self.polymorphic = [
    'CreditCardResource',
  ]

  primary_endpoint 'payment-methods', [:index, :show, :create, :update]

  belongs_to :user
  has_one    :subscription

  attribute :user_id, :uuid, only: [:filterable]

  attribute :id, :uuid

  # attribute :stripe_token, :string, except: [:sortable]

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
