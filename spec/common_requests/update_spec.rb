require 'rails_helper'

RSpec.describe "common_requests#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/common-requests/#{common_request.id}", payload
  end

  describe 'basic update' do
    let!(:common_request) { create(:common_request) }

    let(:payload) do
      {
        data: {
          id: common_request.id.to_s,
          type: 'common-requests',
          attributes: {
            # ... your attrs here
          }
        }
      }
    end

    # Replace 'xit' with 'it' after adding attributes
    xit 'updates the resource' do
      expect(CommonRequestResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { common_request.reload.attributes }
    end
  end
end
