require 'rails_helper'

RSpec.describe "devices#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/devices/#{device.id}", params: params
  end

  describe 'basic fetch' do
    let!(:user) { create(:user) }
    let!(:device) { create(:device, user: user) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'works' do
      expect(DeviceResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('devices')
      expect(d.id).to eq(device.id)
    end
  end
end
