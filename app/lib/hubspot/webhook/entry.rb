module Hubspot
  module Webhook
    class Entry
      attr_reader :payload

      def initialize(payload, webhook_event)
        @payload = payload
        @webhook_event = webhook_event
      end

      def handler
        case @payload["subscriptionType"]
        when "contact.propertyChange"
          return Hubspot::Webhook::Handler::Contact::PropertyChangeJob
        when "contact.creation"
          return Hubspot::Webhook::Handler::Contact::CreationJob
        when "contact.privacyDeletion"
          # Hubspot::Webhook::Handler::Contact::PrivacyDeletionJob
          return
        when "contact.deletion"
          # Hubspot::Webhook::Handler::Contact::DeletionJob
          return
        when "deal.propertyChange"
          Hubspot::Webhook::Handler::Deal::PropertyChangeJob
          return
        when "deal.creation"
          Hubspot::Webhook::Handler::Deal::CreationJob
          return
        when "deal.deletion"
          # Hubspot::Webhook::Handler::Deal::DeletionJob
          return
        end
      end
    end
  end
end
