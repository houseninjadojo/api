require 'rails_helper'

RSpec.describe "users#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/users/#{user.id}", params: params
  end

  describe 'basic fetch' do
    let!(:user) { create(:user) }

    before { allow_any_instance_of(Auth).to receive(:current_user).and_return(user) }

    it 'works' do
      expect(UserResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('users')
      expect(d.id).to eq(user.id)
    end
  end
end
