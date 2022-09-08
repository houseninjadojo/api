# == Schema Information
#
# Table name: estimates
#
#  id                      :uuid             not null, primary key
#  access_token            :string
#  approved_at             :datetime
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

  def shared
    shared_at.present?
  end
  alias_method :shared?, :shared

  def shared=(value)
    self.shared_at = value.present ? Time.now : nil
  end

  def amount
    if homeowner_amount_actual.to_i > 0
      homeowner_amount_actual
    else
      homeowner_amount
    end
  end

  # actions

  def approve!
    return nil if approved?
    update!(approved_at: Time.now)
  end

  def share_with_customer!
    return nil if shared?
    update!(shared_at: Time.now)
    # generate deep link
    Estimate::ExternalAccess::GenerateDeepLinkJob.perform_later(estimate: self)
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
end
