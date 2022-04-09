require 'rails_helper'

RSpec.describe "document_groups#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/document-groups/#{document_group.id}", params: params
  end

  describe 'basic fetch' do
    let!(:document_group) { create(:document_group) }

    it 'works' do
      expect(DocumentGroupResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('document-groups')
      expect(d.id).to eq(document_group.id)
    end
  end
end
