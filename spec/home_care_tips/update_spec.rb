require 'rails_helper'

RSpec.describe "home_care_tips#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/home-care-tips/#{home_care_tip.id}", payload
  end

  describe 'basic update' do
    let!(:home_care_tip) { create(:home_care_tip) }

    let(:payload) do
      {
        data: {
          id: home_care_tip.id.to_s,
          type: 'home-care-tips',
          attributes: {
            # ... your attrs here
          }
        }
      }
    end

    # Replace 'xit' with 'it' after adding attributes
    xit 'updates the resource' do
      expect(HomeCareTipResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { home_care_tip.reload.attributes }
    end
  end
end
