require 'rails_helper'

RSpec.describe "resource_verifications#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/resource-verifications", payload
  end

  describe 'basic create' do
    let(:credit_card) { create(:credit_card) }
    let(:payload) do
      {
        data: {
          type: 'resource-verifications',
          attributes: {
            resource_name: 'credit-cards',
            record_id: credit_card.id,
            attribute: 'cvv',
            value: credit_card.cvv,
          },
        },
      }
    end

    it 'works' do
      expect(ResourceVerificationResource).to receive(:build).and_call_original
      make_request
      expect(response.status).to eq(201), response.body
    end
  end
end
