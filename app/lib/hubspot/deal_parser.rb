module Hubspot
  class DealParser
    attr_accessor :deal_id, :payload

    def initialize(deal)
      @deal_id = deal.object_id
      @payload = deal.properties
    end

    def work_order_params
      params = payload.map{ |k,v| [attribute_name(k), attribute_value(k, v)] }.to_h
      params.merge(
        hubspot_id: deal_id,
        hubspot_object: payload,
      )
    end

    def property_name
      payload["propertyName"]
    end

    def property_value
      if payload["propertyValue"].is_a?(String)
        payload["propertyValue"].strip
      else
        payload["propertyValue"]
      end
    end

    def attribute_name(property_name)
      case property_name
      when "revised_estimate___for_homeowner"
        #
      when "actual_invoice___for_homeowner"
        :homeowner_amount_actual
      when "address"
        :street_address1
      when "amount"
        :total
      when "city"
        :city
      when "closedate"
        # :scheduled_window_start
      when "closed_lost_reason"
        #
      when "closed_won_reason"
        #
      when "createdate"
        :created_at
      when "customer_approved_work_"
        :customer_approved_work
      when "date_estimate_sent"
        # :sent_at
      when "date___time_of_the_walkthrough"
        :walkthrough_date
      when "date_work_completed"
        :completed_at
      when "dealname"
        :description
      when "dealstage"
        :status
      when "dealtype"
        #
      when "description"
        #
      when "email"
        :email
      when "engagements_last_meeting_booked"
        :walkthrough_booking_timestamp
      when "estimate_approved"
        # :customer_approved_estimate
      when "estimate___for_homeowner"
        #
      when "estimate___from_vendor"
        #
      when "est__home_value"
        :estimated_value
      when "firstname"
        :first_name
      when "first_walkthrough_performed_"
        :first_walkthrough_performed
      when "homeowner_name"
        #
      when "hs_lastmodifieddate"
        :updated_at
      when "invoice_for_homeowner"
        :homeowner_amount
        # work_order.homeowner_amount
      when "invoice_from_vendor"
        :vendor_amount
      when "invoice_notes"
        :invoice_notes
      when "job_referred_"
        # :referred
      when "lastname"
        :last_name
      when "lifecyclestage"
        #
      when "mobilephone"
        :phone_number
      when "no__of_bathrooms"
        :bathrooms
      when "number_of_bedrooms"
        :bedrooms
      when "phone"
        :phone_number
      when "pipeline"
        #
      when "preventative_maintenance_plan_pdf"
        :preventative_maintenance_plan_pdf
      when "profit___actual__override_"
        #
      when "refund___make_good____"
        :refund_amount
      when "refund___make_good_reason"
        :refund_reason
      when "scheduled_work_date"
        #
      when "second_estimate___for_homeowner"
        #
      when "second_estimate___from_vendor"
        #
      when "size_of_home__sq_ft_"
        :home_size
      when "state"
        :state
      when "time_of_scheduled_work"
        :scheduled_time
      when "time_of_the_walkthrough"
        :walkthrough_time
      when "vendor_category"
        #
      when "vendor_name"
        :vendor
      when "vendor_paid"
        #
      when "walkthrough_time"
        #
      when "walkthrough_report_pdf"
        :walkthrough_report_pdf
      when "year_built"
        :year_built
      when "zip"
        :zipcode
      end
    end

    def attribute_value(property_name, property_value)
      case property_name
      when "revised_estimate___for_homeowner"
        # attribute_as_amount_in_cents
      when "actual_invoice___for_homeowner"
        attribute_as_amount_in_cents(property_value)
      when "address"
        property_value
      when "amount"
        attribute_as_amount_in_cents(property_value)
      when "city"
        property_value
      when "closedate"
        attribute_as_epoch_time(property_value)
      when "closed_lost_reason"
        property_value
      when "closed_won_reason"
        property_value
      when "createdate"
        attribute_as_epoch_time(property_value)
      when "customer_approved_work_"
        attribute_as_boolean(property_value)
      when "date_estimate_sent"
        # attribute_as_epoch_time(property_value)
      when "date___time_of_the_walkthrough"
        attribute_as_epoch_time(property_value)
      when "date_work_completed"
        attribute_as_epoch_time(property_value)
      when "dealname"
        property_value
      when "dealstage"
        attribute_as_status(property_value)
      when "dealtype"
        #
      when "description"
        property_value
      when "email"
        property_value
      when "engagements_last_meeting_booked"
        attribute_as_epoch_time(property_value)
      when "estimate_approved"
        attribute_as_boolean(property_value)
      when "estimate___for_homeowner"
        attribute_as_amount_in_cents(property_value)
      when "estimate___from_vendor"
        attribute_as_amount_in_cents(property_value)
      when "est__home_value"
        val = property_value.to_s.gsub(/\D/, "")
        Money.from_cents(val).fractional.to_s
      when "firstname"
        property_value
      when "first_walkthrough_performed_"
        attribute_as_boolean
      when "homeowner_name"
        property_value
      when "hs_lastmodifieddate"
        attribute_as_epoch_time(property_value)
      when "invoice_for_homeowner"
        attribute_as_amount_in_cents(property_value)
        # work_order.homeowner_amount
      when "invoice_from_vendor"
        attribute_as_amount_in_cents(property_value)
      when "invoice_notes"
        property_value
      when "job_referred_"
        # attribute_as_boolean
      when "lastname"
        property_value
      when "lifecyclestage"
        #
      when "mobilephone"
        property_value
      when "no__of_bathrooms"
        property_value
      when "number_of_bedrooms"
        property_value
      when "phone"
        property_value
      when "pipeline"
        #
      when "preventative_maintenance_plan_pdf"
        signed_url_attribute_as_io(property_value)
      when "profit___actual__override_"
        #
      when "refund___make_good____"
        attribute_as_amount_in_cents(property_value)
      when "refund___make_good_reason"
        property_value
      when "scheduled_work_date"
        #
      when "second_estimate___for_homeowner"
        #
      when "second_estimate___from_vendor"
        #
      when "size_of_home__sq_ft_"
        property_value
      when "state"
        property_value
      when "time_of_scheduled_work"
        property_value
      when "time_of_the_walkthrough"
        property_value
      when "vendor_name"
        property_value
      when "vendor_paid"
        #
      when "walkthrough_time"
        #
      when "walkthrough_report_pdf"
        signed_url_attribute_as_io(property_value)
      when "year_built"
        property_value
      when "zip"
        property_value
      else
        property_value
      end
    end

    def [](key)
      payload[key]
    end

    # "805.5" => "80550"
    def attribute_as_amount_in_cents(property_value)
      Money.from_amount(property_value.to_f).fractional.to_s
    end

    # "1644204893172" => "2016-04-20T18:53:13.172Z"
    def attribute_as_epoch_time(property_value)
      Time.at(property_value.to_i / 1000).in_time_zone("US/Pacific")
    end

    # "closed" #=> WorkOrderStatus::CLOSED
    def attribute_as_status(property_value)
      WorkOrderStatus.find_by(hubspot_id: property_value)
    end

    # "Yes" #=> true
    # "No"  #=> false
    # ""    #=> nil
    def attribute_as_boolean(property_value)
      case property_value
      when true, false, "true", "false"
        ActiveModel::Type::Boolean.new.cast(property_value)
      when "Yes"
        true
      when "No"
        false
      else
        nil
      end
    end

    def attribute_as_io(property_value)
      URI.open(property_value)
    end

    def signed_url_attribute_as_io(property_value)
      uri = URI.parse(property_value)
      file_id = uri.path&.split("/")&.last
      first_url = "https://api.hubapi.com/files/v3/files/#{file_id}/signed-url?hapikey=#{Rails.secrets.dig(:hubspot, :api_key)}"
      signed_url_payload = OpenURI.open_uri(first_url).read
      signed_url = JSON.parse(signed_url_payload)["url"]
      URI.open(signed_url)
    end
  end
end
