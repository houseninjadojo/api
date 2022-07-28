# == Schema Information
#
# Table name: subscriptions
#
#  id                   :uuid             not null, primary key
#  canceled_at          :datetime
#  current_period_end   :datetime
#  current_period_start :datetime
#  status               :string
#  stripe_object        :jsonb
#  trial_end            :datetime
#  trial_start          :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  payment_method_id    :uuid             not null
#  promo_code_id        :uuid
#  stripe_id            :string
#  subscription_plan_id :uuid             not null
#  user_id              :uuid             not null
#
# Indexes
#
#  index_subscriptions_on_payment_method_id     (payment_method_id)
#  index_subscriptions_on_promo_code_id         (promo_code_id)
#  index_subscriptions_on_stripe_id             (stripe_id) UNIQUE
#  index_subscriptions_on_subscription_plan_id  (subscription_plan_id)
#  index_subscriptions_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (payment_method_id => payment_methods.id)
#  fk_rails_...  (promo_code_id => promo_codes.id)
#  fk_rails_...  (subscription_plan_id => subscription_plans.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Subscription, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
