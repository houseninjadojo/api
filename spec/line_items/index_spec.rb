require 'rails_helper'

RSpec.describe "line_items#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/line-items", params: params
  end

  describe 'basic fetch' do
    let!(:line_item1) { create(:line_item) }
    let!(:line_item2) { create(:line_item) }

    it 'works' do
      expect(LineItemResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['line-items'])
      expect(d.map(&:id)).to match_array([line_item1.id, line_item2.id])
    end
  end
end
