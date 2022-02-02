require 'rails_helper'

RSpec.describe "service_areas#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/service-areas/#{service_area.id}", params: params
  end

  describe 'basic fetch' do
    let!(:service_area) { create(:service_area) }

    it 'works' do
      expect(ServiceAreaResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('service-areas')
      expect(d.id).to eq(service_area.id)
    end
  end
end
