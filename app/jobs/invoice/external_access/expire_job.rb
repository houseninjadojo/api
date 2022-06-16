class Invoice::ExternalAccess::ExpireJob < ApplicationJob
  queue_as :default

  attr_accessor :invoice

  def perform(invoice)
    @invoice = invoice
    return unless conditions_met?

    ActiveRecord::Base.transaction do
      invoice.update(access_token: nil)
      invoice.deep_link.expire! if deep_link.present?
    end
  end

  def conditions_met?
    [
      invoice.present?,
      invoice.deep_link.present?,
    ].all?
  end
end
