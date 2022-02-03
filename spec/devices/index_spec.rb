require 'rails_helper'

RSpec.describe "devices#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/devices", params: params
  end

  describe 'basic fetch' do
    let!(:device1) { create(:device) }
    let!(:device2) { create(:device) }

    xit 'works' do
      expect(DeviceResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['devices'])
      expect(d.map(&:id)).to match_array([device1.id, device2.id])
    end
  end
end
