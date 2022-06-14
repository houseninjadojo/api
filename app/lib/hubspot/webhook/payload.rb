module Hubspot
  module Webhook
    class Payload
      def initialize(webhook_event)
        @webhook_event = webhook_event
      end

      def webhook_payload
        @webhook_event.payload
      end

      def entries
        @entries ||= webhook_payload.map do |entry_payload|
          Hubspot::Webhook::Entry.new(entry_payload, @webhook_event)
        end
      end

      def as_params
        entries.each_with_object({}) do |entry, params|
          params[:hubspot_id] = entry.hubspot_id
          if entry.handler_action == :create
            next
          elsif entry.handler_action == :update
            next if entry.attribute_name.nil?
            params[entry.attribute_name] = entry.attribute_value
          end
        end
      end

      # when a resource is created, hubspot sends several `propertyChange` events,
      # one `creation` event, and 0 other events. We can use this particularity
      # as a kind of "webhook payload signature".
      # @todo remove this after removing deal_batch reliance
      def is_create_batch?
        batch = webhook_payload.pluck("subscriptionType").uniq.sort
        deal_batch = ["deal.propertyChange", "deal.creation"].sort
        contact_batch = ["contact.propertyChange", "contact.creation"].sort
        batch == deal_batch || batch == contact_batch
      end
      alias is_deal_batch? is_create_batch?

      def create_batch_entry
        webhook_payload.entries.find { |i| i["subscriptionType"].split(".").last == "creation" }
      end
      alias deal_batch_entry create_batch_entry
    end
  end
end
