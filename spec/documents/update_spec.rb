require 'rails_helper'

RSpec.describe "documents#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/documents/#{document.id}", payload
  end

  describe 'basic update' do
    let!(:document) { create(:document) }

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
