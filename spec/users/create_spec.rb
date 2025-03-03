require 'rails_helper'

RSpec.describe "users#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/users", payload
  end

  describe 'basic create' do
    let(:params) do
      attributes_for(:user).except(
        :stripe_id,
        :hubspot_id,
        :hubspot_contact_object,
        :arrivy_id
      )
    end
    let(:payload) do
      {
        data: {
          type: 'users',
          attributes: params
        }
      }
    end

    it 'works' do
      expect(UserResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { User.count }.by(1)
    end
  end
end
