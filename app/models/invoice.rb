# == Schema Information
#
# Table name: invoices
#
#  id                   :uuid             not null, primary key
#  access_token         :string
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
#  work_order_id        :uuid
#
# Indexes
#
#  index_invoices_on_access_token     (access_token) UNIQUE
#  index_invoices_on_promo_code_id    (promo_code_id)
#  index_invoices_on_status           (status)
#  index_invoices_on_stripe_id        (stripe_id) UNIQUE
#  index_invoices_on_subscription_id  (subscription_id)
#  index_invoices_on_user_id          (user_id)
#  index_invoices_on_work_order_id    (work_order_id)
#
# Foreign Keys
#
#  fk_rails_...  (promo_code_id => promo_codes.id)
#  fk_rails_...  (subscription_id => subscriptions.id)
#  fk_rails_...  (user_id => users.id)
#
class Invoice < ApplicationRecord
  # statuses
  # @see https://stripe.com/docs/invoicing/integration/workflow-transitions

  STATUS_DELETED = "deleted"
  STATUS_DRAFT = "draft"
  STATUS_OPEN = "open"
  STATUS_UNCOLLECTIBLE = "uncollectible"
  STATUS_PAID = "paid"
  STATUS_VOIDED = "void"

  # callbacks

  # associations

  has_many   :line_items,   dependent: :destroy
  has_one    :deep_link,    dependent: :destroy, as: :linkable
  has_one    :document
  has_one    :payment
  belongs_to :promo_code,   required: false
  belongs_to :subscription, required: false
  belongs_to :user,         required: false
  belongs_to :work_order,   required: false

  # validations

  validates :access_token, uniqueness: true, allow_nil: true
  validates :stripe_id,    uniqueness: true, allow_nil: true

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

  # external access / payment approval

  def generate_access_token!
    return if access_token.present?
    update!(access_token: SecureRandom.hex(32))
  end

  def encrypted_access_token
    @encrypted_access_token ||= Invoice::EncryptedAccessToken.new(self).to_s
  end

  def self.find_by_encrypted_access_token(token)
    payload = EncryptionService.decrypt(token)&.with_indifferent_access
    return unless payload.present?
    find_by(access_token: payload[:access_token])
  end

  def expire_external_access!
    deep_link.expire! if deep_link.present?
  end

  def has_external_access_expired?
    deep_link.present? && deep_link.is_expired?
  end
end
