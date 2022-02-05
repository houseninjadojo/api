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
require 'rails_helper'

RSpec.describe Subscription, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
