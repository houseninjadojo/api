require 'rails_helper'

RSpec.describe "devices#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/devices", payload
  end

  describe 'basic create' do
    let(:params) do
      attributes_for(:device)
    end
    let(:payload) do
      {
        data: {
          type: 'devices',
          attributes: params
        }
      }
    end

    it 'works' do
      expect(DeviceResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { Device.count }.by(1)
    end
  end
end
