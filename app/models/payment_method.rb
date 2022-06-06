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

  # callbacks

  after_create_commit :set_user_onboarding_step

  # associations

  belongs_to :user
  has_one    :subscription
  has_many   :payments

  # validations

  validates :stripe_token, uniqueness: true, allow_nil: true

  # helpers

  # @todo remove this when we consolidate column names
  def stripe_id
    stripe_token
  end

  # callbacks

  def set_user_onboarding_step
    self.user.update(onboarding_step: OnboardingStep::PAYMENT_METHOD)
  end

  # sync

  include Syncable

  after_create_commit  :sync_create!
  after_destroy_commit :sync_delete!

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
