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
class Estimate < ApplicationRecord
  # scopes

  scope :approved, -> { where.not(approved_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :present, -> { where(deleted_at: nil) }
  scope :shared, -> { where.not(shared_at: nil) }

  default_scope { where(deleted_at: nil).order(created_at: :asc) }

  # callbacks

  # `customer_approved_invoice = yes`
  # ``

  # associations

  belongs_to :work_order

  # helpers

  def approved?
    approved_at.present?
  end

  def amount
    if homeowner_amount_actual.to_i > 0
      homeowner_amount_actual
    else
      homeowner_amount
    end
  end
end
