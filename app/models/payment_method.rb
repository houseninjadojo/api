# == Schema Information
#
# Table name: payment_methods
#
#  id           :uuid             not null, primary key
#  type         :string
#  user_id      :uuid             not null
#  stripe_token :string
#  brand        :string
#  country      :string
#  cvv          :string
#  exp_month    :string
#  exp_year     :string
#  card_number  :string
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  last_four    :string
#
# Indexes
#
#  index_payment_methods_on_stripe_token  (stripe_token) UNIQUE
#  index_payment_methods_on_user_id       (user_id)
#
class PaymentMethod < ApplicationRecord
  TYPES = [
    'CreditCard',
  ]

  # callbacks

  after_create_commit :set_user_onboarding_step

  after_create_commit :create_stripe_payment_method,
    unless: -> (payment_method) { payment_method.stripe_token.present? }

  after_save_commit :attach_to_stripe_customer,
    if:     -> (payment_method) { payment_method.saved_change_to_attribute?(:stripe_token, from: nil) },
    unless: -> (payment_method) { payment_method.user_id.empty? }

  after_destroy_commit :detach_from_stripe,
    if: -> (payment_method) { payment_method.stripe_token.present? }

  # associations

  belongs_to :user
  has_one    :subscription
  has_many   :payments

  # validations

  validates :stripe_token, uniqueness: true, allow_nil: true

  # callbacks

  def create_stripe_payment_method
    Stripe::CreatePaymentMethodJob.perform_later(self)
  end

  def attach_to_stripe_customer
    Stripe::AttachPaymentMethodJob.perform_later(self, self.user)
  end

  def detach_from_stripe
    Stripe::DetachPaymentMethodJob.perform_later(self.stripe_token)
  end

  def set_user_onboarding_step
    self.user.update(onboarding_step: OnboardingStep::PAYMENT_METHOD)
  end
end
