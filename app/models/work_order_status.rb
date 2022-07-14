class WorkOrderStatus < ActiveHash::Base
  include ActiveHash::Enum
  self.data = [
    {
      id: "work_request_received",
      name: "Work Request Received",
      slug: "work_request_received",
      hubspot_id: "7430806",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "work_order_initiated",
      name: "Work Order Initiated",
      slug: "work_order_initiated",
      hubspot_id: "15611951",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "sourcing_vendor",
      name: "Sourcing Vendor",
      slug: "sourcing_vendor",
      hubspot_id: "15513135",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "onsite_estimate_scheduled",
      name: "Onsite Estimate Scheduled",
      slug: "onsite_estimate_scheduled",
      hubspot_id: "15513137",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "estimate_shared_with_homeowner",
      name: "Estimate Shared With Homeowner",
      slug: "estimate_shared_with_homeowner",
      hubspot_id: "15513138",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "scheduling_in_progress",
      name: "Scheduling In Progress",
      slug: "scheduling_in_progress",
      hubspot_id: "15513136",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "work_scheduled",
      name: "Work Scheduled",
      slug: "work_scheduled",
      hubspot_id: "7430807",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "work_in_progress",
      name: "Work In Progress",
      slug: "work_in_progress",
      hubspot_id: "15513141",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "change_order_received",
      name: "Change Order Received",
      slug: "change_order_received",
      hubspot_id: "7430808",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "work_completed",
      name: "Work Completed",
      slug: "work_completed",
      hubspot_id: "7430809",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "customer_confirmed_work",
      name: "Customer Confirmed Work",
      slug: "customer_confirmed_work",
      hubspot_id: nil,
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "problem_reported",
      name: "Problem Reported",
      slug: "problem_reported",
      hubspot_id: "7430813",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "problem_being_addressed",
      name: "Problem Being Addressed",
      slug: "problem_being_addressed",
      hubspot_id: "15513142",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "problem_resolved",
      name: "Problem Resolved",
      slug: "problem_resolved",
      hubspot_id: "15513143",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "vendor_invoice_received",
      name: "Vendor Invoice Received",
      slug: "vendor_invoice_received",
      hubspot_id: "7430816",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "invoice_sent_to_customer",
      name: "Invoice Sent To Customer",
      slug: "invoice_sent_to_customer",
      hubspot_id: "7430817",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "invoice_paid_by_customer",
      name: "Invoice Paid By Customer",
      slug: "invoice_paid_by_customer",
      hubspot_id: "7430818",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "closed",
      name: "Closed",
      slug: "closed",
      hubspot_id: "7430811",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "canceled",
      name: "Canceled",
      slug: "canceled",
      hubspot_id: "17702291",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "payment_failed",
      name: "Payment Failed",
      slug: "payment_failed",
      hubspot_id: "17702292",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "paused",
      name: "Paused",
      slug: "paused",
      hubspot_id: "17712235",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "referred_out",
      name: "Referred Out",
      slug: "referred_out",
      hubspot_id: "22379672",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "ready_to_invoice_customer",
      name: "Ready to Invoice Customer",
      slug: "ready_to_invoice_customer",
      hubspot_id: "28090515",
      hubspot_pipeline_id: "2133042",
    },
    {
      id: "home_walkthrough_scheduled",
      name: "Home Walkthrough Scheduled",
      slug: "home_walkthrough_scheduled",
      hubspot_id: "19229774",
      hubspot_pipeline_id: "6430329",
    },
    {
      id: "walkthrough_completed",
      name: "Walkthrough Completed",
      slug: "walkthrough_completed",
      hubspot_id: "19229777",
      hubspot_pipeline_id: "6430329",
    },
    {
      id: "walkthrough_report_sent",
      name: "Walkthrough Report Sent",
      slug: "walkthrough_report_sent",
      hubspot_id: "19229817",
      hubspot_pipeline_id: "6430329",
    },
  ]
  enum_accessor :slug

  # associations

  include ActiveHash::Associations
  has_many :work_orders, class_name: "WorkOrder", primary_key: :status, foreign_key: :slug
  belongs_to :hubspot_pipeline, class_name: 'Hubspot::Deal::Pipeline'

  # helpers

  def self.for(slug)
    find_by(slug: slug)
  end

  def self.for_hubspot_deal(val)
    find_by(hubspot_id: val&.to_s)
  end

  def self.find_by(params)
    params = params.stringify_keys
    super.find_by(params)
  end

  def enabled
    hubspot_pipeline&.enabled?
  end
  alias_method :enabled?, :enabled
end
