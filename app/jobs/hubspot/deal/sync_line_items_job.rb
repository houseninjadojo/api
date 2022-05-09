class Hubspot::Deal::SyncLineItemsJob < ApplicationJob
  queue_as :default

  def perform(deal_id, invoice)
    @deal_id = deal_id
    @invoice = invoice
    return unless conditions_met?

    upsert_line_items!
  end

  private

  def conditions_met?
    [
      @invoice.present?,
      @deal_id.present?,
      !imported_line_items.blank?, # cannot be `nil` nor `[]`
    ]
  end

  def imported_line_items
    @imported_line_items ||= Hubspot::LineItems.for_deal(@deal_id)
  end

  def upsert_line_items!
    @line_items ||= imported_line_items.map do |li|
      line_item = LineItem.find_or_initialize_by(hubspot_id: li[:hubspot_id])
      line_item.assign_attributes(li)
      line_item.invoice = @invoice
      line_item.save!
      line_item
    end
  end
end
