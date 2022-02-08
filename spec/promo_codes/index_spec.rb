require 'rails_helper'

RSpec.describe "promo_codes#index", type: :request do
  let!(:promo_code1) { create(:promo_code) }
  let(:params) { { filter: { code: promo_code1.code } } }

  subject(:make_request) do
    jsonapi_get "/promo-codes", params: params
  end

  describe 'basic fetch' do
    # before {
    #   allow_any_instance_of(Auth).to receive(:current_user).and_return(create(:user))
    # }

    it 'works' do
      expect(PromoCodeResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['promo-codes'])
      expect(d.map(&:id)).to match_array([promo_code1.id])
    end
  end
end
