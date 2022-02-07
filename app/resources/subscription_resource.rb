# == Schema Information
#
# Table name: subscriptions
#
#  id                     :uuid             not null, primary key
#  payment_method_id      :uuid             not null
#  subscription_plan_id   :uuid             not null
#  user_id                :uuid             not null
#  stripe_subscription_id :string
#  status                 :string
#  canceled_at            :datetime
#  trial_start            :datetime
#  trial_end              :datetime
#  current_period_start   :datetime
#  current_period_end     :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_subscriptions_on_payment_method_id       (payment_method_id)
#  index_subscriptions_on_stripe_subscription_id  (stripe_subscription_id)
#  index_subscriptions_on_subscription_plan_id    (subscription_plan_id)
#  index_subscriptions_on_user_id                 (user_id)
#
class SubscriptionResource < ApplicationResource
  self.model = Subscription
  self.type = :subscriptions

  primary_endpoint 'subscriptions', [:index, :show, :create]

  belongs_to :payment_method
  belongs_to :subscription_plan
  belongs_to :user
  has_many   :invoices

  attribute :id, :uuid

  attribute :payment_method_id,    :uuid, only: [:filterable]
  attribute :subscription_plan_id, :uuid, only: [:filterable]
  attribute :user_id,              :uuid, only: [:filterable]

  attribute :status, :string, except: [:writable]

  attribute :canceled_at,          :datetime, except: [:writeable]
  attribute :trial_start,          :datetime, except: [:writeable]
  attribute :trial_end,            :datetime, except: [:writeable]
  attribute :current_period_start, :datetime, except: [:writeable]
  attribute :current_period_end,   :datetime, except: [:writeable]

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
