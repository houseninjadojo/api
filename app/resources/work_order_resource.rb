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
