require 'rails_helper'

RSpec.describe "service_areas#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/service-areas", payload
  end

  describe 'basic create' do
    let(:params) do
      attributes_for(:service_area)
    end
    let(:payload) do
      {
        data: {
          type: 'service_areas',
          attributes: params
        }
      }
    end

    xit 'works' do
      expect(ServiceAreaResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { ServiceArea.count }.by(1)
    end
  end
end
