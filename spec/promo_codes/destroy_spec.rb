require 'rails_helper'

RSpec.describe "promo_codes#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/promo-codes/#{promo_code.id}"
  end

  describe 'basic destroy' do
    let!(:promo_code) { create(:promo_code) }

    xit 'updates the resource' do
      expect(PromoCodeResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { PromoCode.count }.by(-1)
      expect { promo_code.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
