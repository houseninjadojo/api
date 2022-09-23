require 'rails_helper'

RSpec.describe "estimates#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/estimates/#{estimate.id}"
  end

  describe 'basic destroy' do
    let!(:estimate) { create(:estimate) }

    xit 'updates the resource' do
      expect(EstimateResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { Estimate.count }.by(-1)
      expect { estimate.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
