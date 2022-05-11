require 'rails_helper'

RSpec.describe "line_items#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/line-items/#{line_item.id}", params: params
  end

  describe 'basic fetch' do
    let!(:line_item) { create(:line_item) }

    it 'works' do
      expect(LineItemResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('line-items')
      expect(d.id).to eq(line_item.id)
    end
  end
end
