require 'rails_helper'

RSpec.describe "users#update", type: :request do
  subject(:make_request) do
    jsonapi_put "//users/#{user.id}", payload
  end

  describe 'basic update' do
    let!(:user) { create(:user) }

    let(:payload) do
      {
        data: {
          id: user.id.to_s,
          type: 'users',
          attributes: {
            first_name: 'Bob',
            last_name: 'Saget'
          }
        }
      }
    end

    it 'updates the resource' do
      expect(UserResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { user.reload.attributes }
    end
  end
end
