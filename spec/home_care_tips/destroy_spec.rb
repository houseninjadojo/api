require 'rails_helper'

RSpec.describe "home_care_tips#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/home-care-tips/#{home_care_tip.id}"
  end

  describe 'basic destroy' do
    let!(:home_care_tip) { create(:home_care_tip) }

    xit 'updates the resource' do
      expect(HomeCareTipResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { HomeCareTip.count }.by(-1)
      expect { home_care_tip.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
