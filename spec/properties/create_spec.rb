require 'rails_helper'

RSpec.describe "properties#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/properties", payload
  end

  describe 'basic create' do
    let(:service_area) { create(:service_area) }
    let(:user) { create(:user) }
    let(:params) do
      attributes_for(:property)
    end
    let(:payload) do
      {
        data: {
          type: 'properties',
          attributes: params,
          relationships: {
            user: {
              data: {
                type: 'users',
                id: user.id
              }
            },
            service_area: {
              data: {
                type: 'service-areas',
                id: service_area.id
              }
            }
          }
        }
      }
    end

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'works' do
      expect(PropertyResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { Property.count }.by(1)
    end
  end
end
