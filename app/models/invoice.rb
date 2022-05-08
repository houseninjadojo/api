# == Schema Information
#
# Table name: invoices
#
#  id                   :uuid             not null, primary key
#  description          :string
#  finalized_at         :datetime
#  payment_attempted_at :datetime
#  period_end           :datetime
#  period_start         :datetime
#  status               :string
#  stripe_object        :jsonb
#  total                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  promo_code_id        :uuid
#  stripe_id            :string
#  subscription_id      :uuid
#  user_id              :uuid
#
# Indexes
#
#  index_invoices_on_promo_code_id    (promo_code_id)
#  index_invoices_on_status           (status)
#  index_invoices_on_stripe_id        (stripe_id) UNIQUE
#  index_invoices_on_subscription_id  (subscription_id)
#  index_invoices_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (promo_code_id => promo_codes.id)
#  fk_rails_...  (subscription_id => subscriptions.id)
#  fk_rails_...  (user_id => users.id)
#
class Invoice < ApplicationRecord
  # callbacks

  # associations

  has_many   :line_items,   dependent: :destroy
  has_one    :document
  has_one    :payment
  belongs_to :promo_code,   required: false
  belongs_to :subscription, required: false
  belongs_to :user,         required: false

  # validations

  validates :stripe_id, uniqueness: true, allow_nil: true

  # helpers

  def finalized?
    finalized_at.present?
  end

  def paid?
    payment_attempted_at.present? && payment.present?
  end

  def payment_succeeded_at
    payment.try(:created_at)
  end

  # actions

  def pay!
    Stripe::Invoices::PayJob.perform_now(self)
  end

  def fetch_pdf!
    Stripe::Invoices::FetchPdfJob.perform_later(self) unless document.present?
  end

  def finalize!
    Stripe::Invoices::FinalizeJob.perform_now(self) unless finalized?
  end

  # sync

  def create_stripe_invoice
    Stripe::Invoices::CreateJob.perform_later(self) unless stripe_id.present?
  end
end
