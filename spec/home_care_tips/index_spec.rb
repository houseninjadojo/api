require 'rails_helper'

RSpec.describe "home_care_tips#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/home-care-tips", params: params
  end

  describe 'basic fetch' do
    let!(:home_care_tip1) { create(:home_care_tip) }
    let!(:home_care_tip2) { create(:home_care_tip) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(create(:user))
    }

    it 'works' do
      expect(HomeCareTipResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['home-care-tips'])
      expect(d.map(&:id)).to match_array([home_care_tip1.id, home_care_tip2.id])
    end
  end
end
