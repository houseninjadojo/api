# == Schema Information
#
# Table name: work_orders
#
#  id             :uuid             not null, primary key
#  property_id    :uuid             not null
#  status         :string
#  description    :string
#  vendor         :string
#  scheduled_date :string
#  scheduled_time :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_work_orders_on_property_id  (property_id)
#
class WorkOrderResource < ApplicationResource
  self.model = WorkOrder
  self.type = 'work-orders'

  primary_endpoint 'work-orders', [:index, :show, :create, :update]

  belongs_to :property

  attribute :id, :uuid

  attribute :description,    :string, except: [:sortable]
  attribute :vendor,         :string
  attribute :status,         :string, except: [:writeable]
  attribute :scheduled_date, :string, except: [:sortable]
  attribute :scheduled_time, :string, except: [:sortable]

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
