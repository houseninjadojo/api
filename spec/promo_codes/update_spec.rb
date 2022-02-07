require 'rails_helper'

RSpec.describe "promo_codes#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/promo-codes/#{promo_code.id}", payload
  end

  describe 'basic update' do
    let!(:promo_code) { create(:promo_code) }

    let(:payload) do
      {
        data: {
          id: promo_code.id.to_s,
          type: 'promo-codes',
          attributes: {
            # ... your attrs here
          }
        }
      }
    end

    # Replace 'xit' with 'it' after adding attributes
    xit 'updates the resource' do
      expect(PromoCodeResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { promo_code.reload.attributes }
    end
  end
end
