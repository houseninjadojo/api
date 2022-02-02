require 'rails_helper'

RSpec.describe "home_care_tips#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/home-care-tips", payload
  end

  describe 'basic create' do
    let(:params) do
      attributes_for(:home_care_tip)
    end
    let(:payload) do
      {
        data: {
          type: 'home-care-tips',
          attributes: params
        }
      }
    end

    xit 'works' do
      expect(HomeCareTipResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { HomeCareTip.count }.by(1)
    end
  end
end
