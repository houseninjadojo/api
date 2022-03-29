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
#  active          :boolean          default(FALSE), not null
#
# Indexes
#
#  index_subscription_plans_on_active           (active)
#  index_subscription_plans_on_interval         (interval)
#  index_subscription_plans_on_slug             (slug)
#  index_subscription_plans_on_stripe_price_id  (stripe_price_id) UNIQUE
#
class SubscriptionPlan < ApplicationRecord
  # callbacks
  before_save :slugify,
    if: -> (subscription) { subscription.will_save_change_to_attribute?(:slug) }

  # association
  has_many :subscriptions

  # validations
  validates :slug,            presence: true
  validates :name,            presence: true
  validates :price,           presence: true
  validates :interval,        presence: true, inclusion: { in: ['year', 'month'] }
  validates :stripe_price_id, uniqueness: true, allow_nil: true

  # callbacks

  def slugify
    self.slug = self.slug.parameterize
  end
end
