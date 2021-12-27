require 'rails_helper'

RSpec.describe "addresses#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/addresses", payload
  end

  describe 'basic create' do
    let!(:property) { create(:property) }
    let(:params) do
      attributes_for(:address)
    end
    let(:payload) do
      {
        data: {
          type: 'addresses',
          attributes: params,
          relationships: {
            addressible: {
              data: {
                type: 'properties',
                id: property.id
              }
            }
          }
        }
      }
    end

    it 'works' do
      expect(AddressResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { Address.count }.by(1)
    end
  end
end
