require 'rails_helper'

RSpec.describe "users#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/users", params: params
  end

  describe 'basic fetch' do
    let!(:user1) { create(:user) }
    # let!(:user2) { create(:user) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user1)
    }

    it 'works' do
      expect(UserResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['users'])
      expect(d.map(&:id)).to match_array([user1.id])
    end
  end
end
