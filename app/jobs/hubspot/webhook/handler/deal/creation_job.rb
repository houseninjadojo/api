class Hubspot::Webhook::Handler::Deal::CreationJob < ApplicationJob
  queue_as :default

  def perform(webhook_entry, webhook_event)
    @entry = webhook_entry
    return unless conditions_met?

    WorkOrder.create!(work_order_attributes_from_deal)

    webhook_event.update!(processed_at: Time.now)
  end

  private

  def conditions_met?
    [
      webhook_event.processed_at.blank?,
      hubspot_id.present?,
      deal.present?,
      work_order.nil?,
    ].all?
  end

  def work_order_attributes_from_deal
    {
      description: props["dealname"],
      created_at:  time_from_epoch(props["createdate"]),
      updated_at:  time_from_epoch(props["hs_lastmodifieddate"]),
      status:      work_order_status,
      vendor:      props["vendor_name"],

      homeowner_amount: amount_in_cents(props["invoice_from_vendor"]),
      vendor_amount:    amount_in_cents(props["invoice_for_homeowner"]),

      scheduled_window_start: time_from_epoch(props["closedate"]),
      scheduled_window_end: time_from_epoch(props["closedate"]),

      hubspot_id:     deal.deal_id,
      hubspot_object: deal,

      property: property,
    }
  end

  def hubspot_id
    @hubspot_id ||= @entry["objectId"]
  end

  def deal
    @deal ||= Hubspot::Deal.find(hubspot_id)
  end

  def props
    @props ||= deal.properties.with_indifferent_access
  end

  def work_order
    @work_order ||= WorkOrder.find_by(hubspot_id: hubspot_id)
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

  def work_order_status
    work_order_status ||= WorkOrderStatus.find_by(hubspot_id: @props["dealstage"])
  end

  def estimate_attributes
    {
      approved: (props["estimate_approved"] == "true"),
      sent_at: time_from_epoch(props["date_estimate_sent"]),
      homeowner_amount: amount_in_cents(props["estimate___for_homeowner"]),
      vendor_amount: amount_in_cents(props["estimate___from_vendor"]),
    }
  end

  def user_from_contact_association
    @user ||= do
      contacts = Hubspot::Association.all(hubspot_id, Hubspot::Association::DEAL_TO_CONTACT)
      contact = contacts.first
      User.find_by(hubspot_id: contact.id)
    end
  end
  alias user user_from_contact_association

  def property
    @property ||= user_from_contact_association.try(:properties).try(:first)
  end
end
