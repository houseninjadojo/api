require 'rails_helper'

RSpec.describe "addresses#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/addresses/#{address.id}", params: params
  end

  describe 'basic fetch' do
    let!(:address) { create(:address) }

    it 'works' do
      expect(AddressResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('addresses')
      expect(d.id).to eq(address.id)
    end
  end
end
