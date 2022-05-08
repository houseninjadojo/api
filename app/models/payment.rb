# == Schema Information
#
# Table name: payments
#
#  id                   :uuid             not null, primary key
#  amount               :string
#  description          :string
#  paid                 :boolean          default(FALSE), not null
#  refunded             :boolean          default(FALSE), not null
#  statement_descriptor :string
#  status               :string
#  stripe_object        :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  invoice_id           :uuid
#  payment_method_id    :uuid
#  stripe_id            :string
#  user_id              :uuid
#
# Indexes
#
#  index_payments_on_invoice_id         (invoice_id)
#  index_payments_on_payment_method_id  (payment_method_id)
#  index_payments_on_status             (status)
#  index_payments_on_stripe_id          (stripe_id) UNIQUE
#  index_payments_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (invoice_id => invoices.id)
#  fk_rails_...  (payment_method_id => payment_methods.id)
#  fk_rails_...  (user_id => users.id)
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

  def charge_payment_method!(now: true)
    return if has_charge?
    if now == true
      Stripe::CreateChargeJob.perform_now(self)
    else
      Stripe::CreateChargeJob.perform_later(self)
    end
  end
end
