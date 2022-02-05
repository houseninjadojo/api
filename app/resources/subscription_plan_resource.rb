# == Schema Information
#
# Table name: subscription_plans
#
#  id              :uuid             not null, primary key
#  slug            :string           not null
#  name            :string           not null
#  price           :string           not null
#  interval        :string           not null
#  perk            :string           default("")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  stripe_price_id :string
#
# Indexes
#
#  index_subscription_plans_on_interval         (interval)
#  index_subscription_plans_on_slug             (slug)
#  index_subscription_plans_on_stripe_price_id  (stripe_price_id) UNIQUE
#
class SubscriptionPlanResource < ApplicationResource
  self.model = SubscriptionPlan
  self.type = 'subscription-plans'

  primary_endpoint 'subscription-plans', [:index, :show]

  has_many :subscriptions

  attribute :id, :uuid

  attribute :slug,     :string, except: [:writeable]
  attribute :name,     :string, except: [:writeable]
  attribute :price,    :string, except: [:writeable]
  attribute :interval, :string_enum, allow: ["year", "month"], except: [:writeable]
  attribute :perk,     :string, except: [:writeable]

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
