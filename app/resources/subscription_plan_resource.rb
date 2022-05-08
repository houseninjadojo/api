# == Schema Information
#
# Table name: subscription_plans
#
#  id              :uuid             not null, primary key
#  active          :boolean          default(FALSE), not null
#  interval        :string           not null
#  name            :string           not null
#  perk            :string           default("")
#  price           :string           not null
#  slug            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  stripe_price_id :string
#
# Indexes
#
#  index_subscription_plans_on_active           (active)
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

  def base_scope
    SubscriptionPlan.where(active: true)
  end
end
