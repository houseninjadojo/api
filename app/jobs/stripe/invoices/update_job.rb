class Stripe::Invoices::UpdateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ActiveSupport::Deprecation.warn("this job will be deleted, use Sync::Invoice::Stripe::Outbound::CreateJob instead")
  end
end
