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
#  requested_at            :datetime
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
class WorkOrderResource < ApplicationResource
  self.model = WorkOrder
  self.type = 'work-orders'

  primary_endpoint 'work-orders', [:index, :show, :create, :update]

  belongs_to :property
  has_one    :estimate
  has_one    :invoice

  attribute :property_id, :uuid, only: [:filterable]

  attribute :id, :uuid

  attribute :description,    :string, except: [:sortable]
  attribute :vendor,         :string
  attribute :scheduled_date, :string, except: [:sortable]
  attribute :scheduled_time, :string, except: [:sortable]

  attribute :scheduled_window_start, :datetime, only: [:filterable]
  attribute :scheduled_window_end,   :datetime, only: [:filterable]

  attribute :completed_at,  :datetime, only: [:readable]
  attribute :invoice_notes, :string,   only: [:readable]

  attribute :cost, :string, only: [:readable] do
    Money.from_cents(@object.amount)&.format
  end


  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]

  attribute :status, :string, except: [:writeable] do
    @object.status&.slug
  end

  def base_scope
    WorkOrder
      .unscoped
      .available
      .has_status
      .order(
        completed_at: :desc,
        scheduled_window_start: :desc,
        created_at: :desc
      )
  end
end
