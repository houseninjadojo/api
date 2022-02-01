require 'rails_helper'

RSpec.describe "devices#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/devices/#{device.id}"
  end

  describe 'basic destroy' do
    let!(:device) { create(:device) }

    xit 'updates the resource' do
      expect(DeviceResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { Device.count }.by(-1)
      expect { device.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
