# == Schema Information
#
# Table name: estimates
#
#  id                      :uuid             not null, primary key
#  approved_at             :datetime
#  deleted_at              :datetime
#  description             :text
#  homeowner_amount        :string
#  homeowner_amount_actual :string
#  scheduled_at            :datetime
#  scheduled_window_end    :datetime
#  scheduled_window_start  :datetime
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
class EstimateResource < ApplicationResource
  self.model = Estimate
  self.type = :estimates

  primary_endpoint 'estimates', [:index, :show, :update]

  belongs_to :work_order

  attribute :id, :uuid

  attribute :work_order_id, :uuid, only: [:filterable]

  attribute :approved_at, :datetime

  attribute :description, :string, except: [:writeable]

  attribute :scheduled_window_end,   :datetime, except: [:writeable]
  attribute :scheduled_window_start, :datetime, except: [:writeable]

  attribute :vendor_category, :string, except: [:writeable]
  attribute :vendor_name,     :string, except: [:writeable]

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]

  # virtual

  attribute :amount, :string, only: [:readable] do
    Money.from_cents(@object.amount)&.format
  end

  # internal

  def base_scope
    Estimate
      .unscoped
      .present
  end
end
