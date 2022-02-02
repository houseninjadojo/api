# == Schema Information
#
# Table name: subscription_plans
#
#  id         :uuid             not null, primary key
#  slug       :string           not null
#  name       :string           not null
#  price      :string           not null
#  interval   :string           not null
#  perk       :string           default("")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_subscription_plans_on_interval  (interval)
#  index_subscription_plans_on_slug      (slug)
#
class SubscriptionPlan < ApplicationRecord
  # Validations
  validates :slug,     presence: true
  validates :name,     presence: true
  validates :price,    presence: true
  validates :interval, presence: true, inclusion: { in: ['year', 'month'] }

  before_save do |subscription_plan|
    subscription_plan.slug = subscription_plan.slug.parameterize
  end
end
