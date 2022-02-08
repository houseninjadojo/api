require 'rails_helper'

RSpec.describe "promo_codes#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/promo-codes/#{promo_code.id}", params: params
  end

  describe 'basic fetch' do
    let!(:promo_code) { create(:promo_code) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(create(:user))
    }

    it 'works' do
      expect(PromoCodeResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('promo-codes')
      expect(d.id).to eq(promo_code.id)
    end
  end
end
