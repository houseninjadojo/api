class Hubspot::CreateWorkOrderFromDealJob < ApplicationJob
  queue_as :default

  def perform(hubspot_id)
    deal = Hubspot::Deal.find(hubspot_id)
    attributes = mapped_attributes(deal)

    WorkOrder.create!(attributes)
  end

  def mapped_attributes(deal)
    props = deal.properties
    user = user_from_contact_association(deal)
    {
      description: props["dealname"],
      created_at:  time_from_epoch(props["createdate"]),
      updated_at:  time_from_epoch(props["hs_lastmodifieddate"]),
      status:      work_order_status_from_dealstage(props["dealstage"]),
      vendor:      props["vendor_name"],

      homeowner_amount: amount_in_cents(props["invoice_from_vendor"]),
      vendor_amount:    amount_in_cents(props["invoice_for_homeowner"]),

      scheduled_window_start: time_from_epoch(props["closedate"]),
      scheduled_window_end: time_from_epoch(props["closedate"]),

      hubspot_id:     deal.deal_id,
      hubspot_object: deal,

      property: user&.properties&.first,
    }
  end

  def time_from_epoch(epoch)
    epoch = epoch.to_i / 1000
    Time.at(epoch)
  end

  # "805.5" => "80550"
  def amount_in_cents(amount)
    return "0" unless amount.present?
    Money.from_amount(amount.to_f).fractional.to_s
  end

  # def scheduling(closedate)
  #   ts = time_from_epoch(closedate)
  #   {
  #     scheduled_date: ts.strftime("%m/%d/%y"),
  #     scheduled_time: ts.strftime("%I:%M%p"),
  #   }
  # end

  def work_order_status_from_dealstage(dealstage)
    WorkOrderStatus.find_by(hubspot_id: dealstage)
  end

  def estimate_attributes(props)
    {
      approved: (props["estimate_approved"] == "true"),
      sent_at: time_from_epoch(props["date_estimate_sent"]),
      homeowner_amount: amount_in_cents(props["estimate___for_homeowner"]),
      vendor_amount: amount_in_cents(props["estimate___from_vendor"]),
    }
  end

  def user_from_contact_association(deal)
    contacts = Hubspot::Association.all(deal.deal_id, Hubspot::Association::DEAL_TO_CONTACT)
    contact = contacts.first
    User.find_by(hubspot_id: contact.id)
  end
end
