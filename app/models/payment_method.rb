# == Schema Information
#
# Table name: payment_methods
#
#  id           :uuid             not null, primary key
#  brand        :string
#  card_number  :string
#  country      :string
#  cvv          :string
#  exp_month    :string
#  exp_year     :string
#  last_four    :string
#  stripe_token :string
#  type         :string
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#
# Indexes
#
#  index_payment_methods_on_stripe_token  (stripe_token) UNIQUE
#  index_payment_methods_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class PaymentMethod < ApplicationRecord
  TYPES = [
    'CreditCard',
  ]

  scope :active, -> { where.not(stripe_token: nil) }

  # callbacks

  # before_create :ensure_stripe_user_exists!
  after_create_commit :set_user_onboarding_step

  # associations

  belongs_to :user
  has_one    :subscription
  has_many   :payments

  # validations
  before_validation :create_and_attach_to_stripe
  validates :stripe_token, uniqueness: true, allow_nil: true

  # helpers

  # @todo remove this when we consolidate column names
  def stripe_id
    stripe_token
  end

  def stripe_id=(val)
    self.stripe_token = val
  end

  # callbacks

  def set_user_onboarding_step
    if user.is_currently_onboarding?
      self.user.update(onboarding_step: OnboardingStep::WELCOME)
    end
  end

  def ensure_stripe_user_exists!
    if user.stripe_id.nil?
      Sync::User::Stripe::Outbound::CreateJob.perform_now(user)
    end
  end

  def create_and_attach_to_stripe
    return if Rails.env.test?
    current_method = user&.default_payment_method

    self.id = SecureRandom.uuid
    card = CreditCards::CreateAndAttachJob.perform_now(self)

    errors = card&.errors&.messages.dup
    has_errors = errors.respond_to?(:[]) && errors.blank?

    throw(:abort) if !has_errors

    # self.stripe_token = card.id
    # self.last_four = card.card.last4

    # set new default and mark the old
    if has_errors && current_method.present?
      Sync::CreditCard::Stripe::Outbound::DeleteJob.perform_later(current_method)
    end
  end

  # sync

  include Syncable

  # after_create_commit  :sync_create!
  after_destroy_commit :sync_delete!

  def sync_create!
    # return if Rails.env.test?
    # # set user if needed
    # Sync::User::Stripe::Outbound::CreateJob.perform_now(user) unless user&.stripe_id&.present?
    # # grab current payment method for after
    # current_method = user&.default_payment_method
    # # create & attach payment method in stripe
    # new_method = Sync::CreditCard::Stripe::Outbound::CreateJob.perform_now(self)
    # # set new default and mark the old
    # if new_method.persisted? && current_method.present?
    #   Sync::CreditCard::Stripe::Outbound::DeleteJob.perform_later(current_method)
    # end
  end

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
end
