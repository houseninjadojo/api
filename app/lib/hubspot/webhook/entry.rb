module Hubspot
  module Webhook
    # @example payload
    # {
    #   "eventId" => 320936115,
    #   "subscriptionId" => 1444064,
    #   "portalId"=>20553083,
    #   "appId"=>657827,
    #   "occurredAt"=>1644204893172,
    #   "subscriptionType"=>"contact.propertyChange",
    #   "attemptNumber"=>0,
    #   "objectId"=>225501,
    #   "propertyName"=>"email",
    #   "propertyValue"=>"bethlsteinberg@gmail.com",
    #   "changeSource"=>"FORM"
    # }
    class Entry
      attr_accessor :payload

      def initialize(webhook_event, payload)
        @payload = payload.respond_to?(:with_indifferent_access) ? payload.with_indifferent_access : payload
        @webhook_event = webhook_event
      end

      # map the `subscriptionType` value to a corresponding job
      # @example
      #   "contact.creation"    => Sync::User::Hubspot::Inbound::CreateJob
      #   "deal.propertyChange" => Sync::WorkOrder::Hubspot::Inbound::UpdateJob
      def handler
        [
          "Sync",
          "#{handler_klass}",
          "Hubspot",
          "Inbound",
          "#{handler_action.capitalize}Job"
        ].join("::").safe_constantize
      end

      def handler_klass
        if resource_klass == Property
          User
        elsif resource_klass == Estimate
          WorkOrder
        else
          resource_klass
        end
      end

      def handler_action
        action = payload["subscriptionType"].split(".").last #=> "creation"
        case action
        when "creation"
          :create
        when "deletion"
          :delete
        when "propertyChange"
          :update
        when "privacyDeletion"
          SystemMailer.with(payload: payload).privacy_delete_request.deliver_later
          :delete
        end
      end

      def resource_klass
        resource_type = payload["subscriptionType"].split(".").first #=> "contact"
        case resource_type
        when "contact"
          if ["address", "city", "state", "zip"].include?(payload["propertyName"])
            Property
          else
            User
          end
        when "deal"
          if [
            "date_estimate_sent",
            "estimate_approved",
            "estimate_notes",
            "estimate___for_homeowner",
            "estimate___from_vendor",
            "revised_estimate___for_homeowner",
            "second_estimate___for_homeowner",
            "second_estimate___from_vendor",
          ].include?(payload["propertyName"])
            Estimate
          else
            WorkOrder
          end
        end
      end

      def resource
        if resource_klass == Property
          @resource ||= User.find_by(hubspot_id: hubspot_id)&.default_property if hubspot_id.present?
        elsif resource_klass == Invoice
          @resource ||= WorkOrder.find_by(hubspot_id: hubspot_id)&.invoice if hubspot_id.present?
        elsif resource_klass == Estimate
          @resource ||= begin
            work_order = WorkOrder.find_by(hubspot_id: hubspot_id) if hubspot_id.present?
            return nil unless work_order.present?
            work_order&.fetch_or_create_estimate
          end
        else
          @resource ||= resource_klass&.find_by(hubspot_id: hubspot_id) if hubspot_id.present?
        end
      end

      def occured_at
        Time.at(payload["occurredAt"].to_i / 1000)
      end

      def handle_as_document?
        [
          "preventative_maintenance_plan_pdf",
          "walkthrough_report_pdf",
        ].include?(property_name)
      end

      def document_tag
        if property_name == "preventative_maintenance_plan_pdf"
          Document::SystemTags::PMP
        elsif property_name == "walkthrough_report_pdf"
          Document::SystemTags::WALKTHROUGH_REPORT
        end
      end

      def hubspot_id
        payload["objectId"]&.to_s
      end
      alias :id :hubspot_id

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

      def attribute_name
        case property_name
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
          # :created_at
        when "customer_approved_work_"
          :customer_approved_work
        when "date_estimate_sent"
          :shared_at
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
          :approved
        when "estimate_notes"
          :description
        when "estimate___for_homeowner"
          :homeowner_amount
        when "estimate___from_vendor"
          :vendor_amount
        when "est__home_value"
          # :home_value
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
          #
        when "num_associated_contacts"
          :property_id # we need to connect it to the property, not the user directly
        when "number_of_bedrooms"
          #
        when "phone"
          :phone_number
        when "pipeline"
          #
        when "preventative_maintenance_plan_pdf"
          :preventative_maintenance_plan_pdf
        when "refund___make_good____"
          :refund_amount
        when "refund___make_good_reason"
          :refund_reason
        when "revised_estimate___for_homeowner"
          :homeowner_amount_actual
        when "scheduled_work_date"
          #
        when "second_estimate___for_homeowner"
          :homeowner_amount
        when "second_estimate___from_vendor"
          :second_vendor_amount
        when "size_of_home__sq_ft_"
          #
        when "state"
          :state
        when "time_of_scheduled_work"
          :scheduled_time
        when "time_of_the_walkthrough"
          :walkthrough_time
        when "vendor_name"
          :vendor
        when "vendor_paid"
          #
        when "walkthrough_time"
          #
        when "walkthrough_report_pdf"
          :walkthrough_report_pdf
        when "year_built"
          #
        when "zip"
          :zipcode
        end
      end

      def attribute_value
        case property_name
        when "actual_invoice___for_homeowner"
          attribute_as_amount_in_cents
        when "address"
          property_value
        when "amount"
          attribute_as_amount_in_cents
        when "city"
          property_value
        when "closedate"
          attribute_as_epoch_time
        when "closed_lost_reason"
          property_value
        when "closed_won_reason"
          property_value
        # when "createdate"
        #   attribute_as_epoch_time
        when "customer_approved_work_"
          attribute_as_boolean
        when "date_estimate_sent"
          attribute_as_epoch_time
        when "date___time_of_the_walkthrough"
          attribute_as_epoch_time
        when "date_work_completed"
          attribute_as_epoch_time
        when "dealname"
          property_value
        when "dealstage"
          attribute_as_status
        when "dealtype"
          #
        when "description"
          property_value
        when "email"
          property_value
        when "engagements_last_meeting_booked"
          attribute_as_epoch_time
        when "estimate_approved"
          attribute_as_boolean
        when "estimate_notes"
          property_value
        when "estimate___for_homeowner"
          attribute_as_amount_in_cents
        when "estimate___from_vendor"
          attribute_as_amount_in_cents
        when "est__home_value"
          #
        when "firstname"
          property_value
        when "first_walkthrough_performed_"
          attribute_as_boolean
        when "homeowner_name"
          property_value
        when "hs_lastmodifieddate"
          attribute_as_epoch_time
        when "invoice_for_homeowner"
          attribute_as_amount_in_cents
          # work_order.homeowner_amount
        when "invoice_from_vendor"
          attribute_as_amount_in_cents
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
          #
        when "number_of_bedrooms"
          #
        when "num_associated_contacts"
          attribute_as_property_id
        when "phone"
          property_value
        when "pipeline"
          #
        when "preventative_maintenance_plan_pdf"
          signed_url_attribute_as_io
        when "refund___make_good____"
          attribute_as_amount_in_cents
        when "refund___make_good_reason"
          property_value
        when "revised_estimate___for_homeowner"
          attribute_as_amount_in_cents
        when "scheduled_work_date"
          #
        when "second_estimate___for_homeowner"
          attribute_as_amount_in_cents
        when "second_estimate___from_vendor"
          attribute_as_amount_in_cents
        when "size_of_home__sq_ft_"
          #
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
          signed_url_attribute_as_io
        when "year_built"
          #
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
      def attribute_as_amount_in_cents
        Money.from_amount(property_value.to_f).fractional.to_s
      end

      # "1644204893172" => "2016-04-20T18:53:13.172Z"
      def attribute_as_epoch_time
        Time.at(property_value.to_i / 1000).in_time_zone("US/Pacific")
      end

      # "closed" #=> WorkOrderStatus::CLOSED
      def attribute_as_status
        WorkOrderStatus.find_by(hubspot_id: property_value)
      end

      # "Yes" #=> true
      # "No"  #=> false
      # ""    #=> nil
      def attribute_as_boolean
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

      def attribute_as_io
        URI.open(property_value)
      end

      def signed_url_attribute_as_io
        uri = URI.parse(property_value)
        file_id = uri.path&.split("/")&.last
        first_url = "https://api.hubapi.com/files/v3/files/#{file_id}/signed-url?hapikey=#{Rails.secrets.dig(:hubspot, :api_key)}"
        signed_url_payload = OpenURI.open_uri(first_url).read
        signed_url = JSON.parse(signed_url_payload)["url"]
        URI.open(signed_url)
      end

      def attribute_as_property_id
        user&.default_property&.id
      end

      # fetch hubspot stuff

      def hubspot_contact
        contacts = Hubspot::Association.all("Deal", hubspot_id, "Contact") || []
        contacts.first
      end

      def user
        User.find_by(hubspot_id: hubspot_contact&.id)
      end
    end
  end
end
