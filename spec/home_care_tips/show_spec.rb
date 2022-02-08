require 'rails_helper'

RSpec.describe "home_care_tips#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/home-care-tips/#{home_care_tip.id}", params: params
  end

  describe 'basic fetch' do
    let!(:home_care_tip) { create(:home_care_tip) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(create(:user))
    }

    it 'works' do
      expect(HomeCareTipResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('home-care-tips')
      expect(d.id).to eq(home_care_tip.id)
    end
  end
end
