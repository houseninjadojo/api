require 'rails_helper'

RSpec.describe "document_groups#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/document-groups/#{document_group.id}", payload
  end

  describe 'basic update' do
    let!(:user) { create(:user) }
    let!(:document_group) { create(:document_group, user: user) }

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

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'updates the resource' do
      expect(DocumentGroupResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { document_group.reload.attributes }
    end
  end
end
