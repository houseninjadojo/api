require 'rails_helper'

RSpec.describe "promo_codes#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/promo-codes", params: params
  end

  describe 'basic fetch' do
    let!(:promo_code1) { create(:promo_code) }
    let!(:promo_code2) { create(:promo_code) }

    it 'works' do
      expect(PromoCodeResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['promo-codes'])
      expect(d.map(&:id)).to match_array([promo_code1.id, promo_code2.id])
    end
  end
end
