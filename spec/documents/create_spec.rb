require 'rails_helper'

RSpec.describe "documents#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/documents", payload
  end

  describe 'basic create' do
    let(:user) { create(:user) }
    let(:params) do
      attributes_for(:document)
    end
    let(:payload) do
      {
        data: {
          type: 'documents',
          attributes: params,
          relationships: {
            user: {
              data: {
                type: 'users',
                id: user.id
              }
            }
          }
        }
      }
    end

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    xit 'works' do
      expect(DocumentResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { Document.count }.by(1)
    end
  end
end
