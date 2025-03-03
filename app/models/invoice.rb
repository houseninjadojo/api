# == Schema Information
#
# Table name: invoices
#
#  id                   :uuid             not null, primary key
#  access_token         :string
#  description          :string
#  finalized_at         :datetime
#  paid_at              :date
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
#  fk_rails_...  (work_order_id => work_orders.id) ON DELETE => cascade
#
class Invoice < ApplicationRecord
  # statuses
  # @see https://stripe.com/docs/invoicing/integration/workflow-transitions

  STATUS_DELETED = "deleted"
  STATUS_DRAFT = "draft"
  STATUS_OPEN = "open"
  STATUS_UNCOLLECTIBLE = "uncollectible"
  STATUS_PAID = "paid"
  STATUS_PAYMENT_FAILED = "payment_failed"
  STATUS_VOIDED = "void"

  # callbacks

  after_create_commit :sync_stripe_create
  # after_update_commit :sync_stripe_update
  after_update_commit :handle_status_change, if: :saved_change_to_status?

  # associations

  has_many   :line_items,   dependent: :destroy
  has_one    :deep_link,    dependent: :destroy, as: :linkable
  has_one    :document, -> { where(tags: [Document::SystemTags::INVOICE]) }
  has_one    :payment
  has_one    :receipt, -> { where(tags: [Document::SystemTags::RECEIPT]) }, class_name: 'Document'
  belongs_to :promo_code,   required: false
  belongs_to :subscription, required: false
  belongs_to :user,         required: false
  belongs_to :work_order,   required: false

  # validations

  validates :access_token, uniqueness: true, allow_nil: true
  validates :stripe_id,    uniqueness: true, allow_nil: true

  # helpers

  def description
    super || notes
  end

  def notes
    work_order&.invoice_notes
  end

  def user
    super.presence || work_order&.property&.user
  end

  def formatted_total
    format = I18n.t(:format, scope: 'number.currency.format')
    Money.from_cents(total)&.format(format: format)
  end

  def formatted_total=(val)
    # no-op
  end

  def open?
    status == STATUS_OPEN
  end

  def finalized?
    open? && finalized_at.present?
  end

  def draft?
    # payment_attempted_at.present? && payment.present?
    status == STATUS_DRAFT
  end

  def paid?
    # payment_attempted_at.present? && payment.present?
    status == STATUS_PAID
  end

  def payment_succeeded_at
    payment.try(:created_at)
  end

  def can_be_finalized?
    work_order&.can_finalize_invoice?
  end

  def stripe_invoice_number
    obj = begin
      if stripe_object.is_a?(String)
        JSON.parse(stripe_object)
      else
        stripe_object
      end
    rescue
      {}
    end
    obj&.dig('number')
  end

  # actions

  def send_payment_approval_email!
    unless work_order&.customer_approved_work
      Rails.logger.info("Not sending payment approval email, customer has not approved work for work_order=#{work_order&.id}")
    end
    Campaign::PaymentApprovalJob.perform_later(user: user, invoice: self)
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
    return if payload.nil? || has_external_access_expired?
    find_by(access_token: payload[:access_token])
  end

  def expire_external_access!
    update!(access_token: nil)
    deep_link.expire! if deep_link.present?
  end

  def has_external_access_expired?
    deep_link.present? && deep_link.is_expired?
  end

  # sync

  def sync_stripe_create
    if Sync::Invoice::Stripe::Outbound::CreatePolicy.new(self).can_sync?
      Sync::Invoice::Stripe::Outbound::CreateJob.perform_later(self)
    end
  end

  # def sync_stripe_update
  #   if Sync::Invoice::Stripe::Outbound::UpdatePolicy.new(self).can_sync?
  #     Sync::Invoice::Stripe::Outbound::UpdateJob.perform_later(self)
  #   end
  # end

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
      :update,
      # :delete,
    ]
  end

  def sync_associations
    [
      :work_order,
    ]
  end

  # callbacks

  def handle_status_change
    case status
    when STATUS_OPEN
      Invoice::ExternalAccess::GenerateDeepLinkJob.perform_later(invoice: self, send_email: true)
      Invoice::NotifyJob.perform_later(self)
    when STATUS_PAID
      Invoice::ExternalAccess::ExpireJob.perform_later(self)
      work_order&.update!(status: WorkOrderStatus::INVOICE_PAID_BY_CUSTOMER)
    when STATUS_PAYMENT_FAILED
      work_order&.update!(status: WorkOrderStatus::PAYMENT_FAILED)
    end
  end
end
