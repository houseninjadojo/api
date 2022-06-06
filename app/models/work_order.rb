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
  
  after_update_commit :sync_update!

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

  def sync_services
    [
      # :arrivy,
      # :auth0,
      :hubspot,
      # :stripe,
    ]
  end

  def sync_create!
    # sync_services.each { |service| sync!(service: service, action: :create) }
  end

  def sync_update!
    sync_services.each { |service| sync!(service: service, action: :update) }
  end

  def sync_delete!
    # sync_services.each { |service| sync!(service: service, action: :delete) }
  end

  def should_sync_service?(service:, action:)
    policy = "Sync::#{self.class.name}::#{service.capitalize}::Outbound::#{action.capitalize}Policy".constantize
    case action
    when :create
      # policy.new(self).can_sync?
    when :update
      policy.new(self, changed_attributes: self.changed_attributes).can_sync?
    when :delete
      # policy.new(self).can_sync?
    end
  end

  def sync!(service:, action:)
    job = "Sync::#{self.class.name}::#{service.capitalize}::Outbound::#{action.capitalize}Job".constantize
    return unless should_sync_service?(service: service, action: action)
    case action
    when :create
      # job.perform_later(self)
    when :update
      job.perform_later(self, self.saved_changes)
    when :delete
      # job.perform_later(self)
    end
  end

  def should_sync?
    self.saved_changes? &&                        # only sync if there are changes
    self.saved_changes.keys != ['updated_at'] &&  # do not sync if no attributes actually changed
    self.previously_new_record? == false &&       # do not sync if this is a new record
    self.new_record? == false                     # do not sync if it is not persisted
  end
  alias :should_sync_outbound? :should_sync?
end
