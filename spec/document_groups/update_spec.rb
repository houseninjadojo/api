require 'rails_helper'

RSpec.describe "document_groups#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/document-groups/#{document_group.id}", payload
  end

  describe 'basic update' do
    let!(:document_group) { create(:document_group) }

    let(:payload) do
      {
        data: {
          id: document_group.id.to_s,
          type: 'document-groups',
          attributes: {
            name: 'New name'
          }
        }
      }
    end

    # Replace 'xit' with 'it' after adding attributes
    xit 'updates the resource' do
      expect(DocumentGroupResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { document_group.reload.attributes }
    end
  end
end
