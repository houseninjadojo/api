# == Schema Information
#
# Table name: work_orders
#
#  id                      :uuid             not null, primary key
#  completed_at            :datetime
#  customer_approved_work  :boolean
#  description             :string
#  homeowner_amount        :string
#  homeowner_amount_actual :string
#  hubspot_object          :jsonb
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
#  hubspot_id              :string
#  property_id             :uuid
#
# Indexes
#
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

  after_create_commit :sync_create!
  after_create_commit :create_invoice!
  after_update        :sync_total
  after_update_commit :sync_update!

  # associations

  belongs_to :property,  required: false
  belongs_to :status,    class_name: "WorkOrderStatus", primary_key: :slug, foreign_key: :status, required: false
  has_one    :invoice,   dependent: :destroy
  # has_one    :deep_link, through: :invoice
  # has_one    :user,      through: :property

  # validations

  validates :hubspot_id, uniqueness: true, allow_nil: true

  # helpers

  def amount
    total = homeowner_amount_actual || homeowner_amount
    if refund_amount.present?
      total - refund_amount
    else
      total || 0
    end
  end

  def deep_link
    invoice&.deep_link
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

  def sync_total
    if invoice.present? && invoice.total != amount
      invoice.update(total: amount)
    end
  end

  # def handle_status_change
  #   case status.slug
  #   # create external access
  #   when "invoice_sent_to_customer"
  #     invoice.finalize!
  #     Invoice::ExternalAccess::GenerateDeepLinkJob.perform_later(invoice)
  #   when "invoice_paid_by_customer"
  #     Invoice::ExternalAccess::ExpireJob.perform_later(invoice)
  #   end
  # end

  # sync

  include Syncable

  def sync_services
    [
      # :arrivy,
      # :auth0,
      :hubspot,
      # :stripe,
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
