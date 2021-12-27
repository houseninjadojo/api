require 'rails_helper'

RSpec.describe "properties#update", type: :request do
  subject(:make_request) do
    jsonapi_put "//properties/#{property.id}", payload
  end

  describe 'basic update' do
    let(:property) { create(:property) }

    let(:payload) do
      {
        data: {
          id: property.id.to_s,
          type: 'properties',
          attributes: {
            lot_size: 123_456,
            pools: 10
          }
        }
      }
    end

    it 'updates the resource' do
      expect(PropertyResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { property.reload.attributes }
    end
  end
end
