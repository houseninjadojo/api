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

      # when a deal is created, hubspot sends several `propertyChange` events,
      # one `creation` event, and 0 other events. We can use this particularity
      # as a kind of "webhook payload signature".
      def is_deal_batch?
        webhook_payload.pluck("subscriptionType").uniq == ["deal.propertyChange", "deal.creation"]
      end

      def deal_batch_entry
        webhook_payload.entries.find { |i| i["subscriptionType"] == "deal.creation" }
      end
    end
  end
end
