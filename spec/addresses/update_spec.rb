require 'rails_helper'

RSpec.describe "addresses#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/addresses/#{address.id}", payload
  end

  describe 'basic update' do
    let(:address) { create(:address) }

    let(:payload) do
      {
        data: {
          id: address.id.to_s,
          type: 'addresses',
          attributes: {
            street1: '1 abc street',
            street2: 'street line 2'
          }
        }
      }
    end

    it 'updates the resource' do
      expect(AddressResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { address.reload.attributes }
    end
  end
end
