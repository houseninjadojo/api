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
      Invoice::ExternalAccess::GenerateDeepLinkJob.perform_later(invoice)
    when "invoice_paid_by_customer"
      Invoice::ExternalAccess::ExpireJob.perform_later(invoice)
    end
  end
end
