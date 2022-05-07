# == Schema Information
#
# Table name: payments
#
#  id                   :uuid             not null, primary key
#  invoice_id           :uuid
#  user_id              :uuid
#  payment_method_id    :uuid
#  amount               :string
#  description          :string
#  statement_descriptor :string
#  status               :string
#  refunded             :boolean          default(FALSE), not null
#  paid                 :boolean          default(FALSE), not null
#  stripe_id            :string
#  stripe_object        :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_payments_on_invoice_id         (invoice_id)
#  index_payments_on_payment_method_id  (payment_method_id)
#  index_payments_on_status             (status)
#  index_payments_on_stripe_id          (stripe_id) UNIQUE
#  index_payments_on_user_id            (user_id)
#
class Payment < ApplicationRecord
  # callbacks

  # associations

  belongs_to :invoice
  belongs_to :payment_method, required: false
  belongs_to :user,           required: false

  # validations

  validates :stripe_id, uniqueness: true, allow_nil: true

  # helpers

  def paid?
    status == 'succeeded'
  end

  def pending?
    status == 'pending'
  end

  def failed?
    status == 'failed'
  end

  def has_charge?
    stripe_object.present?
  end
  alias was_charged? has_charge?

  # actions

  def charge_payment_method!
    return if has_charge?
    Stripe::CreateChargeJob.perform_now(self)
  end
end
