# == Schema Information
#
# Table name: estimates
#
#  id                      :uuid             not null, primary key
#  access_token            :string
#  approved_at             :datetime
#  declined_at             :datetime
#  deleted_at              :datetime
#  description             :text
#  homeowner_amount        :string
#  homeowner_amount_actual :string
#  scheduled_at            :datetime
#  scheduled_window_end    :datetime
#  scheduled_window_start  :datetime
#  second_vendor_amount    :string
#  shared_at               :datetime
#  vendor_amount           :string
#  vendor_category         :string
#  vendor_name             :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  work_order_id           :uuid             not null
#
# Indexes
#
#  index_estimates_on_approved_at    (approved_at)
#  index_estimates_on_shared_at      (shared_at)
#  index_estimates_on_work_order_id  (work_order_id)
#
# Foreign Keys
#
#  fk_rails_...  (work_order_id => work_orders.id)
#
class Estimate < ApplicationRecord
  # scopes

  scope :approved, -> { where.not(approved_at: nil) }
  scope :declined, -> { where.not(declined_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :present, -> { where(deleted_at: nil) }
  scope :shared, -> { where.not(shared_at: nil) }
  scope :externally_accessible, -> { where.not(access_token: nil) }
  scope :with_user, -> (user) {
    joins(work_order: :property).where(property: { user_id: user.id })
  }

  default_scope { where(deleted_at: nil).order(created_at: :asc) }

  # callbacks

  after_update_commit :sync_update!
  after_update_commit :update_work_order_status,
    if: Proc.new { saved_change_to_approved_at? || saved_change_to_declined_at? }
  after_update_commit :sync_after_approval!,
    if: Proc.new { saved_change_to_approved_at? || saved_change_to_declined_at? }

  # associations

  belongs_to :work_order
  has_one    :deep_link, dependent: :destroy, as: :linkable

  has_one :property, through: :work_order
  has_one :user, through: :property, source: :user, class_name: 'User'

  # validations

  validates :access_token, uniqueness: true, allow_nil: true

  # attributes

  def approved
    approved_at.present?
  end
  alias_method :approved?, :approved

  def approved=(value)
    self.approved_at = value.present? ? Time.now : nil
  end

  def declined
    declined_at.present?
  end
  alias_method :declined?, :declined

  def declined=(value)
    self.declined_at = value.present? ? Time.now : nil
  end

  def shared
    shared_at.present?
  end
  alias_method :shared?, :shared

  def shared=(value)
    self.shared_at = value.present? ? Time.now : nil
  end

  def deleted=(value)
    self.deleted_at = value.present? ? Time.now : nil
  end

  def deleted
    deleted_at.present?
  end
  alias_method :deleted?, :deleted

  def amount
    if homeowner_amount_actual.to_i > 0
      homeowner_amount_actual
    else
      homeowner_amount
    end
  end

  def amount=(value)
    # no-op
  end

  def formatted_total
    format = I18n.t(:format, scope: 'number.currency.format')
    Money.from_cents(amount)&.format(format: format)
  end

  def should_share_with_customer?
    !(declined? || approved? || deleted?)
  end

  def deep_link
    DeepLink.find_by(linkable: self)
  end

  # actions

  def approve!
    return nil if approved?
    update!(approved_at: Time.now)
  end

  def share_with_customer!
    return nil if !should_share_with_customer?
    update!(shared_at: Time.now)
    # generate deep link
    Estimate::ExternalAccess::GenerateDeepLinkJob.perform_later(estimate: self, send_email: true)
    # notify
    Estimate::NotifyJob.perform_later(self)
  end

  # external access / estimate approval

  def generate_access_token!
    return if access_token.present?
    update!(access_token: SecureRandom.hex(32))
  end

  def encrypted_access_token
    @encrypted_access_token ||= Estimate::EncryptedAccessToken.new(self).to_s
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

  def send_estimate_approval_email!
    if !should_share_with_customer?
      Rails.logger.info("Not sending estimate approval email, customer has already decided on estimate for work_order=#{work_order&.id}")
    end
    EstimateMailer.with(
      user: user,
      estimate: self
    ).estimate_approval.deliver_later
  end

  # force it
  def sync_after_approval!(bypass_status_check: false)
    statuses = ["scheduling_in_progress", "sourcing_vendor"]
    if (!approved? && !declined?) || (!statuses.include?(work_order.reload&.status&.slug) || !bypass_status_check)
      Rails.logger.info("Not syncing after approval, estimate=#{id} is not approved/declined or work_order=#{work_order&.id} is not in scheduling_in_progress")
      return
    end
    # for some reason we need to clear the enqueued job lock
    Estimate::ExternalAccess::ExpireJob.unlock!(estimate: self)
    Estimate::ExternalAccess::ExpireJob.perform_later(estimate: self)
    Sync::Estimate::Hubspot::Outbound::UpdateJob.perform_later(
      self,
      [{ path: [:approved_at] }], # mimicking a changeset
    )
    # for some reason we need to clear the enqueued job lock
    Sync::WorkOrder::Hubspot::Outbound::UpdateJob.unlock!(self, [{ path: [:status] }])
    Sync::WorkOrder::Hubspot::Outbound::UpdateJob.perform_later(
      self.work_order,
      [{ path: [:status] }], # mimicking a changeset
    )
  end

  # sync

  include Syncable

  def sync_services
    [
      :hubspot,
    ]
  end

  def sync_actions
    [
      :update,
    ]
  end

  def sync_associations
    [
      :work_order,
    ]
  end

  def update_work_order_status
    if approved_at.present?
      work_order.update!(status: WorkOrderStatus::SCHEDULING_IN_PROGRESS)
      sync_after_approval!(bypass_status_check: true) # i guess we have to force it
    elsif declined_at.present?
      work_order.update!(status: WorkOrderStatus::SOURCING_VENDOR)
      sync_after_approval!(bypass_status_check: true) # i guess we have to force it
    end
  end
end
