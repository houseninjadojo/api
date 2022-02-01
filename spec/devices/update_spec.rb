require 'rails_helper'

RSpec.describe "devices#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/devices/#{device.id}", payload
  end

  describe 'basic update' do
    let!(:device) { create(:device) }

    let(:payload) do
      {
        data: {
          id: device.id.to_s,
          type: 'devices',
          attributes: {
            # ... your attrs here
          }
        }
      }
    end

    # Replace 'xit' with 'it' after adding attributes
    xit 'updates the resource' do
      expect(DeviceResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { device.reload.attributes }
    end
  end
end
