class Invoice::ExternalAccess::ExpireJob < ApplicationJob
  queue_as :default

  def perform(invoice)
    return if invoice.nil?
    invoice.expire_external_access!
  end
end
