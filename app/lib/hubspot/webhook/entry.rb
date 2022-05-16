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
          # return Hubspot::Webhook::Handler::Contact::PrivacyDeletionJob
        when "contact.deletion"
          # return Hubspot::Webhook::Handler::Contact::DeletionJob
        when "deal.propertyChange"
          return Hubspot::Webhook::Handler::Deal::PropertyChangeJob
        when "deal.creation"
          return Hubspot::Webhook::Handler::Deal::CreationJob
        when "deal.deletion"
          # return Hubspot::Webhook::Handler::Deal::DeletionJob
        end
      end
    end
  end
end
