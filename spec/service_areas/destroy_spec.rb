require 'rails_helper'

RSpec.describe "service_areas#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/service-areas/#{service_area.id}"
  end

  describe 'basic destroy' do
    let!(:service_area) { create(:service_area) }

    xit 'updates the resource' do
      expect(ServiceAreaResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { ServiceArea.count }.by(-1)
      expect { service_area.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
