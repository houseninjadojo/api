class Invoice::ExternalAccess::ExpireJob < ApplicationJob
  queue_as :default
  unique :until_executed

  attr_accessor :invoice

  def perform(invoice)
    @invoice = invoice
    return unless conditions_met?

    ActiveRecord::Base.transaction do
      invoice.update(access_token: nil)
      DeepLink.find_by(linkable: invoice)&.expire!
    end
  end

  def conditions_met?
    [
      invoice.present?,
      invoice.deep_link.present?,
    ].all?
  end
end
