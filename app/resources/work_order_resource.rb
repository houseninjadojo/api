# == Schema Information
#
# Table name: work_orders
#
#  id                     :uuid             not null, primary key
#  property_id            :uuid             not null
#  status                 :string
#  description            :string
#  vendor                 :string
#  scheduled_date         :string
#  scheduled_time         :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  hubspot_id             :string
#  hubspot_object         :jsonb
#  homeowner_amount       :string
#  vendor_amount          :string
#  scheduled_window_start :datetime
#  scheduled_window_end   :datetime
#
# Indexes
#
#  index_work_orders_on_hubspot_id   (hubspot_id) UNIQUE
#  index_work_orders_on_property_id  (property_id)
#
class WorkOrderResource < ApplicationResource
  self.model = WorkOrder
  self.type = 'work-orders'

  primary_endpoint 'work-orders', [:index, :show, :create, :update]

  belongs_to :property

  attribute :property_id, :uuid, only: [:filterable]

  attribute :id, :uuid

  attribute :description,    :string, except: [:sortable]
  attribute :vendor,         :string
  attribute :scheduled_date, :string, except: [:sortable]
  attribute :scheduled_time, :string, except: [:sortable]

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]

  attribute :status, :string, except: [:writeable] do
    @object.status.slug
  end
end
