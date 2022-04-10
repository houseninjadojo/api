require 'rails_helper'

RSpec.describe "document_groups#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/document-groups", params: params
  end

  describe 'basic fetch' do
    let!(:user) { create(:user) }
    let!(:document_group1) { create(:document_group, user: user) }
    let!(:document_group2) { create(:document_group, user: user) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'works' do
      expect(DocumentGroupResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['document-groups'])
      expect(d.map(&:id)).to match_array([document_group1.id, document_group2.id])
    end
  end
end
