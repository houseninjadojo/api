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
#  stripe_object          :jsonb
#  promo_code_id          :uuid
#
# Indexes
#
#  index_subscriptions_on_payment_method_id       (payment_method_id)
#  index_subscriptions_on_promo_code_id           (promo_code_id)
#  index_subscriptions_on_stripe_subscription_id  (stripe_subscription_id)
#  index_subscriptions_on_subscription_plan_id    (subscription_plan_id)
#  index_subscriptions_on_user_id                 (user_id)
#
class Subscription < ApplicationRecord
  # callbacks

  after_create_commit :set_user_onboarding_step

  # after_create_commit :create_stripe_subscription,
  #   unless: -> (subscription) { subscription.stripe_subscription_id.present? }

  # associations

  belongs_to :promo_code, required: false
  belongs_to :payment_method
  belongs_to :subscription_plan
  belongs_to :user

  # validations

  validates :stripe_subscription_id, uniqueness: true, allow_nil: true

  # callbacks

  def create_stripe_subscription
    return if stripe_subscription_id.present?
    Stripe::CreateSubscriptionJob.perform_later(self)
  end

  def charge_and_subscribe!
    return if stripe_subscription_id.present?
    Stripe::CreateSubscriptionJob.perform_now(self)
  end

  def cancel_stripe_subscription
    Stripe::CancelSubscriptionJob.perform_later(self)
  end

  def set_user_onboarding_step
    # user.update(onboarding_step: OnboardingStep::WELCOME)
    user.update(onboarding_step: OnboardingStep::SET_PASSWORD)
  end
end
