require 'rails_helper'

RSpec.describe "properties#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/properties", params: params
  end

  describe 'basic fetch' do
    let!(:property1) { create(:property) }
    let!(:property2) { create(:property) }

    it 'works' do
      expect(PropertyResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['properties'])
      expect(d.map(&:id)).to match_array([property1.id, property2.id])
    end
  end
end
