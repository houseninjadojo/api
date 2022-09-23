require 'rails_helper'

RSpec.describe "estimates#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/estimates", payload
  end

  describe 'basic create' do
    let(:params) do
      attributes_for(:estimate)
    end
    let(:payload) do
      {
        data: {
          type: 'estimates',
          attributes: params
        }
      }
    end

    xit 'works' do
      expect(EstimateResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { Estimate.count }.by(1)
    end
  end
end
