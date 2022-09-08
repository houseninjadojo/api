require 'rails_helper'

RSpec.describe "estimates#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/estimates/#{estimate.id}", params: params
  end

  describe 'basic fetch' do
    let!(:estimate) { create(:estimate) }

    it 'works' do
      expect(EstimateResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('estimates')
      expect(d.id).to eq(estimate.id)
    end
  end
end
