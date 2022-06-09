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

      # when a deal is created, hubspot sends several `propertyChange` events,
      # one `creation` event, and 0 other events. We can use this particularity
      # as a kind of "webhook payload signature".
      def is_deal_batch?
        webhook_payload.pluck("subscriptionType").uniq.sort == ["deal.propertyChange", "deal.creation"].sort
      end

      def deal_batch_entry
        webhook_payload.entries.find { |i| i["subscriptionType"] == "deal.creation" }
      end
    end
  end
end
