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
#  index_subscriptions_on_stripe_id             (stripe_id)
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

  after_create :sync_create!
  # after_update_commit :sync_update!
  after_destroy_commit :sync_delete!

  after_create_commit :resync_user!

  # associations

  belongs_to :promo_code, required: false
  belongs_to :payment_method
  belongs_to :subscription_plan
  belongs_to :user

  # validations

  validates :stripe_id, uniqueness: true, allow_nil: true

  # gates

  def active?
    status == STATUS::ACTIVE
  end

  # callbacks

  def set_user_onboarding_step
    # user.update(onboarding_step: OnboardingStep::WELCOME)
    user.update(onboarding_step: OnboardingStep::SET_PASSWORD)
  end

  # sync

  include Syncable

  def sync_services
    [
      # :arrivy,
      # :auth0,
      # :hubspot,
      :stripe,
    ]
  end

  def sync_actions
    [
      :create,
      # :update,
      :delete,
    ]
  end

  def sync_create!
    # we want to ensure we are charging the card BEFORE returning the http request to the user
    # furthermore we are invoking this with `after_create` instead of `after_create_commit`, so that
    # the result of the charge attempt fails the transaction and the subscription is not created on our end either
    response = Sync::Subscription::Stripe::Outbound::CreateJob.perform_now(self)
    if response.is_a?(Stripe::StripeError)
      raise ActiveRecord::RecordNotSaved.new(response.message, self)
    end
  end

  def resync_user!
    user&.sync_update!
  end
end
