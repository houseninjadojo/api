require 'rails_helper'

RSpec.describe "common_requests#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/common-requests", payload
  end

  describe 'basic create' do
    let(:params) do
      attributes_for(:common_request)
    end
    let(:payload) do
      {
        data: {
          type: 'common-requests',
          attributes: params
        }
      }
    end

    xit 'works' do
      expect(CommonRequestResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { CommonRequest.count }.by(1)
    end
  end
end
