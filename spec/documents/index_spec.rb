require 'rails_helper'

RSpec.describe "documents#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/documents", params: params
  end

  describe 'basic fetch' do
    let!(:user) { create(:user) }
    let!(:document1) { create(:document, user: user) }
    let!(:document2) { create(:document, user: user) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'works' do
      expect(DocumentResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['documents'])
      expect(d.map(&:id)).to match_array([document1.id, document2.id])
    end
  end
end
