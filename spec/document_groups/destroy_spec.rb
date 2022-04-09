require 'rails_helper'

RSpec.describe "document_groups#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/document-groups/#{document_group.id}"
  end

  describe 'basic destroy' do
    let!(:document_group) { create(:document_group) }

    it 'updates the resource' do
      expect(DocumentGroupResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { DocumentGroup.count }.by(-1)
      expect { document_group.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
