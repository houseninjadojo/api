require 'rails_helper'

RSpec.describe "service_areas#index", type: :request do
  let(:params) { { filter: { zipcodes: [78702] } } }

  subject(:make_request) do
    jsonapi_get "/service-areas", params: params
  end

  describe 'basic fetch' do
    let!(:service_area1) { create(:service_area) }
    let!(:service_area2) { create(:service_area) }

    it 'works' do
      expect(ServiceAreaResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['service-areas'])
      expect(d.map(&:id)).to match_array([service_area1.id, service_area2.id])
    end
  end
end
