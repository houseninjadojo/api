# == Schema Information
#
# Table name: work_orders
#
#  id                     :uuid             not null, primary key
#  description            :string
#  homeowner_amount       :string
#  hubspot_object         :jsonb
#  scheduled_date         :string
#  scheduled_time         :string
#  scheduled_window_end   :datetime
#  scheduled_window_start :datetime
#  status                 :string
#  vendor                 :string
#  vendor_amount          :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  hubspot_id             :string
#  property_id            :uuid
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
  after_save_commit :handle_status_change, if: :saved_change_to_status?
  after_update_commit :sync!

  # associations

  belongs_to :property, required: false
  belongs_to :status,   class_name: "WorkOrderStatus", primary_key: :slug, foreign_key: :status
  has_one    :invoice,  dependent: :destroy

  # validations

  validates :hubspot_id, uniqueness: true, allow_nil: true

  # callbacks

  def handle_status_change
    case status.slug
    # create external access
    when "invoice_sent_to_customer"
      invoice.finalize!
      Invoice::ExternalAccess::GenerateDeepLinkJob.perform_later(invoice)
    when "invoice_paid_by_customer"
      Invoice::ExternalAccess::ExpireJob.perform_later(invoice)
    end
  end

  # sync

  def should_sync?
    self.saved_changes? &&                        # only sync if there are changes
    self.saved_changes.keys != ['updated_at'] &&  # do not sync if no attributes actually changed
    self.previously_new_record? == false &&       # do not sync if this is a new record
    self.new_record? == false                     # do not sync if it is not persisted
  end

  def sync_jobs
    [
      Sync::WorkOrder::Hubspot::OutboundJob,
    ]
  end

  def sync!
    return unless should_sync?
    sync_jobs.each do |job|
      job.perform_later(self, self.saved_changes)
    end
  end
end
