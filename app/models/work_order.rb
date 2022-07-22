# == Schema Information
#
# Table name: work_orders
#
#  id                      :uuid             not null, primary key
#  completed_at            :datetime
#  customer_approved_work  :boolean
#  deleted_at              :datetime
#  description             :string
#  homeowner_amount        :string
#  homeowner_amount_actual :string
#  hubspot_object          :jsonb
#  invoice_notes           :text
#  refund_amount           :string
#  refund_reason           :string
#  scheduled_date          :string
#  scheduled_time          :string
#  scheduled_window_end    :datetime
#  scheduled_window_start  :datetime
#  status                  :string
#  vendor                  :string
#  vendor_amount           :string
#  walkthrough_date        :datetime
#  walkthrough_time        :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  arrivy_id               :string
#  hubspot_id              :string
#  property_id             :uuid
#
# Indexes
#
#  index_work_orders_on_arrivy_id    (arrivy_id) UNIQUE
#  index_work_orders_on_deleted_at   (deleted_at)
#  index_work_orders_on_hubspot_id   (hubspot_id) UNIQUE
#  index_work_orders_on_property_id  (property_id)
#
# Foreign Keys
#
#  fk_rails_...  (property_id => properties.id)
#
class WorkOrder < ApplicationRecord
  # after_save_commit :handle_status_change, if: :saved_change_to_status?

  before_create :set_status
  before_save :ensure_invoice_status_conditions

  after_create_commit :sync_create!
  after_create_commit :create_invoice!, unless: :is_walkthrough?
  after_update        :sync_total
  after_update        :sync_invoice_notes
  after_update_commit :sync_update!
  after_update_commit :finalize_invoice!, if: :saved_change_to_status?

  # associations

  belongs_to :property,  required: false
  belongs_to :status,    class_name: "WorkOrderStatus", primary_key: :slug, foreign_key: :status, required: false
  has_one    :invoice,   dependent: :destroy
  has_one    :deep_link, through: :invoice
  # has_one    :user,      through: :property

  # scopes

  scope :has_status, -> { where.not(status: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :available, -> { where(deleted_at: nil) }

  # validations

  validates :hubspot_id, uniqueness: true, allow_nil: true

  # helpers

  def amount
    if homeowner_amount_actual.to_i > 0
      homeowner_amount_actual
    else
      homeowner_amount
    end
  end

  def total=(val)
    self.homeowner_amount_actual = val
  end

  def is_walkthrough?
    description.include?("Home Walkthrough:")
  end

  # deconstruct timestamp into date and time attributes on save
  def walkthrough_booking_timestamp=(val)
    self.scheduled_date = val.strftime("%m/%d/%Y")
    self.scheduled_time = val.strftime("%I:%M %p")
    self.scheduled_window_start = val
    self.walkthrough_date = val
  end

  def user
    property&.user
  end

  # callbacks

  def set_status
    self.status ||= WorkOrderStatus.find_by(slug: 'work_request_received')
  end

  def create_invoice!
    Invoice.create!(
      total: amount,
      # user: user,
      work_order: self,
    )
  end

  def finalize_invoice!
    return unless invoice&.can_be_finalized?
    Sync::Invoice::Stripe::Outbound::UpdateJob.perform_later(
      invoice,
      [{ path: [:work_order, :status] }], # mimicking a changeset
    )
  end

  def sync_total
    if invoice.present? && invoice.total != amount
      invoice.update(total: amount)
    end
  end

  def sync_invoice_notes
    if invoice.present?
      invoice.update(description: invoice_notes)
    end
  end

  def ensure_invoice_status_conditions
    if status == WorkOrderStatus::INVOICE_SENT_TO_CUSTOMER
      status = self.status_was if !customer_approved_work || amount == 0
    end
  end

  # sync

  include Syncable

  def sync_services
    [
      :arrivy,
      # :auth0,
      :hubspot,
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
      :invoice,
    ]
  end
end
