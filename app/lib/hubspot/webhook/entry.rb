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

      def initialize(payload, webhook_event)
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
          "#{handler_action}Job"
        ].join("::").safe_constantize
      end

      def handler_action
        action = payload["subscriptionType"].split(".").last #=> "creation"
        case action
        when "creation"
          "Create"
        when "deletion"
          "Delete"
        when "propertyChange"
          "Update"
        when "privacyDeletion"
          # nothing for now
        end
      end

      def resource_klass
        resource_type = payload["subscriptionType"].split(".").first #=> "contact"
        case resource_type
        when "contact"
          User
        when "deal"
          WorkOrder
        end
      end

      def resource
        @resource ||= resource_klass&.find_by(hubspot_id: hubspot_id)
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
        payload["propertyValue"]
      end

      def attribute_name
        case property_name
        when "amount"
          :total
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
        when "estimate_approved"
          :approved
        when "estimate___for_homeowner"
          #
        when "estimate___from_vendor"
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
        when "vendor_name"
          :vendor
        end
      end

      def attribute_value
        case property_name
        when "amount"
          attribute_as_amount_in_cents
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
        when "estimate_approved"
          attribute_as_boolean
        when "estimate___for_homeowner"
          attribute_as_amount_in_cents
        when "estimate___from_vendor"
          attribute_as_amount_in_cents
        when "hs_lastmodifieddate"
          attribute_as_epoch_time
        when "invoice_for_homeowner"
          attribute_as_amount_in_cents
          # work_order.homeowner_amount
        when "invoice_from_vendor"
          attribute_as_amount_in_cents
        when "invoice_notes"
          property_value
        when "vendor_name"
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
        WorkOrderStatus.find_by(slug: property_value)
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
