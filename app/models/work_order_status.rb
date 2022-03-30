# == Schema Information
#
# Table name: work_order_statuses
#
#  id         :uuid             not null, primary key
#  slug       :string           not null
#  name       :string
#  hubspot_id :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_work_order_statuses_on_hubspot_id  (hubspot_id) UNIQUE
#  index_work_order_statuses_on_slug        (slug) UNIQUE
#
class WorkOrderStatus < ApplicationRecord
  # associations
  has_many :work_orders, class_name: "WorkOrder", primary_key: :status, foreign_key: :slug

  # callbacks
  before_save do |status|
    if status.name.empty?
      status.name = status.slug.titleize
    end
  end

  # validations
  validates :slug,       uniqueness: true
  validates :hubspot_id, uniqueness: true, allow_nil: true
end
