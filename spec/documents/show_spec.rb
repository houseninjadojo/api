require 'rails_helper'

RSpec.describe "documents#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/documents/#{document.id}", params: params
  end

  describe 'basic fetch' do
    let!(:user) { create(:user) }
    let!(:document) { create(:document, user: user) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'works' do
      expect(DocumentResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('documents')
      expect(d.id).to eq(document.id)
    end
  end
end
