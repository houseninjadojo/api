module Hubspot
  class Deal
    class Pipeline < ActiveHash::Base
      self.data = [
        {
          id: "2133042",
          slug: "work_orders",
          hubspot_id: "2133042",
          name: "Work Orders",
          enabled: true,
        },
        {
          id: "6430329",
          slug: "home_walkthrough",
          hubspot_id: "6430329",
          name: "Home Walkthrough",
          enabled: true,
        },
        {
          id: "8582970",
          slug: "real_estate_partner_pipeline",
          hubspot_id: "8582970",
          name: "Real Estate Partner Pipeline",
          enabled: false,
        },
        {
          id: "8419103",
          slug: "channel_partner_pipeline",
          hubspot_id: "8419103",
          name: "Channel Partner Pipeline",
          enabled: false,
        },
      ]

      include ActiveHash::Associations
      has_many :work_order_statuses, primary_key: :hubspot_id,
                                     foreign_key: :hubspot_pipeline_id

      def label
        name
      end

      def pipeline_id
        hubspot_id
      end

      def stages
        work_order_statuses
      end
    end
  end
end
