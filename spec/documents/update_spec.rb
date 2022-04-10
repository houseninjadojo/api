require 'rails_helper'

RSpec.describe "documents#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/documents/#{document.id}", payload
  end

  describe 'basic update' do
    let!(:user) { create(:user) }
    let!(:document) { create(:document, user: user) }

    let(:payload) do
      {
        data: {
          id: document.id.to_s,
          type: 'documents',
          attributes: {
            # ... your attrs here
          }
        }
      }
    end

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    # Replace 'xit' with 'it' after adding attributes
    xit 'updates the resource' do
      expect(DocumentResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { document.reload.attributes }
    end
  end
end
