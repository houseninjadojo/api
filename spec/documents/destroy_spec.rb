require 'rails_helper'

RSpec.describe "documents#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/documents/#{document.id}"
  end

  describe 'basic destroy' do
    let(:user) { create(:user) }
    let!(:document) { create(:document, user: user) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    xit 'updates the resource' do
      expect(DocumentResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { Document.count }.by(-1)
      expect { document.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
