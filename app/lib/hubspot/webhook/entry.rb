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
        @payload = payload
        @webhook_event = webhook_event
      end

      # map the `subscriptionType` value to a corresponding job
      # @example
      #   "contact.creation"    => Sync::User::Hubspot::Inbound::CreateJob
      #   "deal.propertyChange" => Sync::WorkOrder::Hubspot::Inbound::UpdateJob
      def handler
        [
          "Sync",
          "#{resource_klass}",
          "Hubspot",
          "Inbound",
          "#{handler_action.capitalize}Job"
        ].join("::").safe_constantize
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
          # nothing for now
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
          WorkOrder
        end
      end

      def resource
        if resource_klass == Property
          @resource ||= User.find_by(hubspot_id: hubspot_id)&.default_property
        else
          @resource ||= resource_klass&.find_by(hubspot_id: hubspot_id)
        end
      end

      def occured_at
        Time.at(payload["occurredAt"].to_i / 1000)
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
        when "date_estimate_sent"
          :sent_at
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
        when "estimate_approved"
          :approved
        when "estimate___for_homeowner"
          #
        when "estimate___from_vendor"
          #
        when "firstname"
          :first_name
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
          :description
        when "lastname"
          :last_name
        when "phone"
          :phone_number
        when "pipeline"
          #
        when "state"
          :state
        when "vendor_name"
          :vendor
        when "zip"
          :zipcode
        end
      end

      def attribute_value
        case property_name
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
        when "createdate"
          attribute_as_epoch_time
        when "date_estimate_sent"
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
        when "estimate_approved"
          attribute_as_boolean
        when "estimate___for_homeowner"
          attribute_as_amount_in_cents
        when "estimate___from_vendor"
          attribute_as_amount_in_cents
        when "firstname"
          property_value
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
        when "lastname"
          property_value
        when "phone"
          property_value
        when "pipeline"
          #
        when "state"
          property_value
        when "vendor_name"
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
      def attribute_as_amount_in_cents
        Money.from_amount(property_value.to_f).fractional.to_s
      end

      # "1644204893172" => "2016-04-20T18:53:13.172Z"
      def attribute_as_epoch_time
        Time.at(property_value.to_i / 1000)
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
        when "Yes"
          true
        when "No"
          false
        else
          nil
        end
      end
    end
  end
end
