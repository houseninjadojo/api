require 'rails_helper'

RSpec.describe "addresses#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/addresses", params: params
  end

  describe 'basic fetch' do
    let!(:address1) { create(:address) }
    let!(:address2) { create(:address) }

    it 'works' do
      expect(AddressResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['addresses'])
      expect(d.map(&:id)).to match_array([address1.id, address2.id])
    end
  end
end
