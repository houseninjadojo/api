require 'rails_helper'

RSpec.describe "estimates#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/estimates/#{estimate.id}", payload
  end

  describe 'basic update' do
    let!(:estimate) { create(:estimate) }

    let(:payload) do
      {
        data: {
          id: estimate.id.to_s,
          type: 'estimates',
          attributes: {
            approved_at: Time.now,
          }
        }
      }
    end

    it 'updates the resource' do
      expect(EstimateResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { estimate.reload.attributes }
    end
  end
end
