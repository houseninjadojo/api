# == Schema Information
#
# Table name: subscriptions
#
#  id                     :uuid             not null, primary key
#  canceled_at            :datetime
#  current_period_end     :datetime
#  current_period_start   :datetime
#  status                 :string
#  stripe_object          :jsonb
#  trial_end              :datetime
#  trial_start            :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  payment_method_id      :uuid             not null
#  promo_code_id          :uuid
#  stripe_subscription_id :string
#  subscription_plan_id   :uuid             not null
#  user_id                :uuid             not null
#
# Indexes
#
#  index_subscriptions_on_payment_method_id       (payment_method_id)
#  index_subscriptions_on_promo_code_id           (promo_code_id)
#  index_subscriptions_on_stripe_subscription_id  (stripe_subscription_id)
#  index_subscriptions_on_subscription_plan_id    (subscription_plan_id)
#  index_subscriptions_on_user_id                 (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (payment_method_id => payment_methods.id)
#  fk_rails_...  (promo_code_id => promo_codes.id)
#  fk_rails_...  (subscription_plan_id => subscription_plans.id)
#  fk_rails_...  (user_id => users.id)
#
class Subscription < ApplicationRecord
  module STATUS
    INCOMPLETE = 'incomplete'
    INCOMPLETE_EXPIRED = 'incomplete_expired'
    TRIALING = 'trialing'
    ACTIVE = 'active'
    PAST_DUE = 'past_due'
    CANCELED = 'canceled'
    UNPAID = 'unpaid'

    ALL = [
      INCOMPLETE,
      INCOMPLETE_EXPIRED,
      TRIALING,
      ACTIVE,
      PAST_DUE,
      CANCELED,
      UNPAID,
    ]
  end

  # callbacks

  after_create_commit :set_user_onboarding_step
  after_create_commit :save_contact_promo_code

  # after_create_commit :create_stripe_subscription,
  #   unless: -> (subscription) { subscription.stripe_subscription_id.present? }

  # associations

  belongs_to :promo_code, required: false
  belongs_to :payment_method
  belongs_to :subscription_plan
  belongs_to :user

  # validations

  validates :stripe_subscription_id, uniqueness: true, allow_nil: true

  # gates

  def active?
    status == STATUS::ACTIVE
  end

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

  def save_contact_promo_code
    Hubspot::Contact::SavePromoCodeJob.perform_later(user, promo_code)
  end
end
