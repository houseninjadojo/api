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
  SLUGS = [
    "work_request_received",
    "work_order_initiated",
    "sourcing_vendor",
    "onsite_estimate_scheduled",
    "estimate_shared_with_homeowner",
    "scheduling_in_progress",
    "work_scheduled",
    "work_in_progress",
    "change_order_received",
    "work_completed",
    "customer_confirmed_work",
    "problem_reported",
    "problem_being_addressed",
    "problem_resolved",
    "vendor_invoice_received",
    "invoice_sent_to_customer",
    "invoice_paid_by_customer",
    "closed",
    "canceled",
    "payment_failed",
    "paused",
    "referred_out"
  ].freeze

  # set up constants for easier reference
  #
  # @note Run `rails db:seed::work_order_statuses` if this is returning nil
  #
  # @example
  #   WorkOrderStatus::PAYMENT_FAILED
  #     #=> #<WorkOrderStatus:0x000000011782d2b0 id: "12345-ASDF-....", slug: "payment_failed", name: "Payment Failed", ...>
  #
  # @return [WorkOrderStatus, nil] the status object, or nil if not synced with hubspot
  SLUGS.each {|slug| const_set(slug.upcase, find_by(slug: slug)) }

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

  # helpers

  def self.for(slug)
    find_by(slug: slug)
  end
end
