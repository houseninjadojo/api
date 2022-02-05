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
require 'rails_helper'

RSpec.describe SubscriptionPlan, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
