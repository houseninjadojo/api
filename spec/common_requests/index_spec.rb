require 'rails_helper'

RSpec.describe "common_requests#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/common-requests", params: params
  end

  describe 'basic fetch' do
    let!(:common_request1) { create(:common_request) }
    let!(:common_request2) { create(:common_request) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(create(:user))
    }

    it 'works' do
      expect(CommonRequestResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['common-requests'])
      expect(d.map(&:id)).to match_array([common_request1.id, common_request2.id])
    end
  end
end
