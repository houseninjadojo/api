require 'rails_helper'

RSpec.describe "service_areas#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/service-areas/#{service_area.id}", payload
  end

  describe 'basic update' do
    let!(:service_area) { create(:service_area) }

    let(:payload) do
      {
        data: {
          id: service_area.id.to_s,
          type: 'service-areas',
          attributes: {
            # ... your attrs here
          }
        }
      }
    end

    # Replace 'xit' with 'it' after adding attributes
    xit 'updates the resource' do
      expect(ServiceAreaResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { service_area.reload.attributes }
    end
  end
end
