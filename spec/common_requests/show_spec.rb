require 'rails_helper'

RSpec.describe "common_requests#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/common-requests/#{common_request.id}", params: params
  end

  describe 'basic fetch' do
    let!(:common_request) { create(:common_request) }

    it 'works' do
      expect(CommonRequestResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('common-requests')
      expect(d.id).to eq(common_request.id)
    end
  end
end
