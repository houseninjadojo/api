require 'rails_helper'

RSpec.describe "documents#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/documents/#{document.id}", params: params
  end

  describe 'basic fetch' do
    let!(:document) { create(:document) }

    it 'works' do
      expect(DocumentResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('documents')
      expect(d.id).to eq(document.id)
    end
  end
end
