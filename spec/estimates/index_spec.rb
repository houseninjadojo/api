require 'rails_helper'

RSpec.describe "estimates#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/estimates", params: params
  end

  describe 'basic fetch' do
    let!(:estimate1) { create(:estimate) }
    let!(:estimate2) { create(:estimate) }

    it 'works' do
      expect(EstimateResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['estimates'])
      expect(d.map(&:id)).to match_array([estimate1.id, estimate2.id])
    end
  end
end
