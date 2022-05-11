module Hubspot
  class LineItems
    # Fetch a list of associated line items for a given hubspot deal
    #
    # 1. use hubspot crm search to get list of line items filtered by deal id
    # =>
    #   {"total"=>2,
    #    "results"=>
    #     [{"id"=>"3030773142",
    #       "properties"=>
    #       {"amount"=>"1000.000",
    #         "createdate"=>"2022-05-07T05:02:08.156Z",
    #         "description"=>nil,
    #         "hs_lastmodifieddate"=>"2022-05-07T05:02:08.156Z",
    #         "hs_object_id"=>"3030773142",
    #         "name"=>"test line item",
    #         "price"=>"1000",
    #         "quantity"=>"1"},
    #       "createdAt"=>"2022-05-07T05:02:08.156Z",
    #       "updatedAt"=>"2022-05-07T05:02:08.156Z",
    #       "archived"=>false},
    #     {"id"=>"3030325675",
    #       "properties"=>
    #       {"amount"=>"1234.000",
    #         "createdate"=>"2022-05-07T05:06:36.967Z",
    #         "description"=>nil,
    #         "hs_lastmodifieddate"=>"2022-05-07T05:06:36.967Z",
    #         "hs_object_id"=>"3030325675",
    #         "name"=>"asdf",
    #         "price"=>"1234",
    #         "quantity"=>"1"},
    #       "createdAt"=>"2022-05-07T05:06:36.967Z",
    #       "updatedAt"=>"2022-05-07T05:06:36.967Z",
    #       "archived"=>false}]}
    #
    # 2. map the hubspot line item properties into a format useable by our ORM
    # =>
    #   [{:hubspot_id=>"3030773142",
    #     :amount=>"1000.000",
    #     :description=>nil,
    #     :name=>"test line item",
    #     :price=>"1000",
    #     :quantity=>"1",
    #     :created_at=>"2022-05-07T05:02:08.156Z",
    #     :updated_at=>"2022-05-07T05:02:08.156Z"},
    #   {:hubspot_id=>"3030325675",
    #     :amount=>"1234.000",
    #     :description=>nil,
    #     :name=>"asdf",
    #     :price=>"1234",
    #     :quantity=>"1",
    #     :created_at=>"2022-05-07T05:06:36.967Z",
    #     :updated_at=>"2022-05-07T05:06:36.967Z"}]
    def self.for_deal(hubspot_deal_id)
      endpoint = "https://api.hubapi.com/crm/v3/objects/line_items/search?hapikey=#{Rails.secrets.hubspot[:api_key]}"
      headers = { "Content-Type" => "application/json" }
      payload = {
        "filters": [
          {
            "propertyName": "associations.deal",
            "operator": "EQ",
            "value": "#{hubspot_deal_id}"
          }
        ],
        "properties": [
          "amount",
          "description",
          "name",
          "price",
          "quantity",
          "createdate",
          "hs_lastmodifieddate",
          "hs_object_id",
        ]
      }
      raw_response = RestClient.post(endpoint, payload.to_json, headers)
      res = JSON.parse(raw_response.body)
      res["results"].map do |line_item|
        props = line_item["properties"]
        {
          hubspot_id: line_item["id"] || props["hs_object_id"],
          amount: props["amount"].present? && Money.from_amount(props["amount"]&.to_f).cents,
          description: props["description"],
          name: props["name"],
          quantity: props["quantity"],
          created_at: props["createdate"],
          updated_at: props["hs_lastmodifieddate"],
        }
      end
    end
  end
end
