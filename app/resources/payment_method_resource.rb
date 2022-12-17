# == Schema Information
#
# Table name: payment_methods
#
#  id           :uuid             not null, primary key
#  brand        :string
#  card_number  :string
#  country      :string
#  cvv          :string
#  deleted_at   :datetime
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

  def base_scope
    PaymentMethod.active.order(created_at: :desc).limit(1)
  end

  def save(model_instance)
    # do the save
    model_instance.save
    # check if the error is because of a pre-existing stripe token
    if model_instance.errors.of_kind?(:stripe_token, :taken)
      model_instance = PaymentMethod.find_by(stripe_token: model_instance.stripe_token)
    end
    # return the model instance
    model_instance
  end
end
