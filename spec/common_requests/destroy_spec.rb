require 'rails_helper'

RSpec.describe "common_requests#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/common-requests/#{common_request.id}"
  end

  describe 'basic destroy' do
    let!(:common_request) { create(:common_request) }

    xit 'updates the resource' do
      expect(CommonRequestResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { CommonRequest.count }.by(-1)
      expect { common_request.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
