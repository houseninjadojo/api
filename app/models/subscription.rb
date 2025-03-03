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

  # after_create_commit :set_user_onboarding_step

  # after_create :sync_create!
  # after_update_commit :sync_update!
  # after_destroy_commit :sync_delete!

  after_create_commit :resync_user!

  # associations

  belongs_to :promo_code, required: false
  belongs_to :payment_method, validate: false
  belongs_to :subscription_plan
  belongs_to :user
  has_many :invoices

  # validations

  validates :stripe_id, uniqueness: true

  # gates

  def active?
    status == STATUS::ACTIVE || status == STATUS::TRIALING
  end

  def canceled?
    status == STATUS::CANCELED
  end

  # callbacks

  # def set_user_onboarding_step
  #   if user.is_currently_onboarding?
  #     user.update(onboarding_step: OnboardingStep::WELCOME)
  #   end
  # end

  # helpers

  def destroy
    false
    # Rails.logger.info("Cancelling subscription=#{id} for user=#{user_id}")
    # if active? == false || canceled_at.present?
    #   Rails.logger.info("Cannot cancel subscription=#{id}. It is already cancelled.")
    #   return
    # end
    # sync_delete!
  end

  def destroy!
    destroy
  end

  # def destroyed?
  #   canceled_at.present?
  # end

  # def deleted?
  #   canceled_at.present?
  # end

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

  def sync_associations
    [
      :user,
    ]
  end

  def sync_create!
    return if Rails.env.test?
    # we want to ensure we are charging the card BEFORE returning the http request to the user
    # furthermore we are invoking this with `after_create` instead of `after_create_commit`, so that
    # the result of the charge attempt fails the transaction and the subscription is not created on our end either
    Rails.logger.info("Trying to create subscription=#{id}")
    response = Sync::Subscription::Stripe::Outbound::CreateJob.perform_now(self)
    if response.is_a?(Stripe::StripeError)
      Rails.logger.info("Error creating subscription=#{id} - #{response.message}")
      raise ActiveRecord::RecordNotSaved.new(response.message, self)
    else
      Rails.logger.info("Finished creating subscription=#{id}")
      # todo WHY DO WE NEED THIS CARVEOUT
      Sync::User::Hubspot::Outbound::UpdateJob.perform_later(
        user,
        [{ path: [:subscription, :status] }], # mimicking a changeset
      )
    end
  end

  def resync_user!
    user&.sync_update!
  end

  def self.params_from_stripe(stripe_object)
  # sub = Stripe::Subscription.retrieve(subid)
    payment_method = PaymentMethod.find_by(stripe_token: stripe_object.default_payment_method)
    subscription_plan = SubscriptionPlan.find_by(stripe_price_id: stripe_object.plan.id)
    user = User.find_by(stripe_id: stripe_object.customer)
    {
      stripe_id: stripe_object.id,
      canceled_at: Time.safe_at(stripe_object.canceled_at),
      current_period_end: Time.safe_at(stripe_object.current_period_end),
      current_period_start: Time.safe_at(stripe_object.current_period_start),
      status: stripe_object.status,
      stripe_object: stripe_object.as_json,
      trial_end: Time.safe_at(stripe_object.trial_end),
      trial_start: Time.safe_at(stripe_object.trial_start),
      created_at: Time.safe_at(stripe_object.created),
      payment_method_id: payment_method&.id,
      subscription_plan_id: subscription_plan&.id,
      user_id: user&.id,
    }
  end
end
