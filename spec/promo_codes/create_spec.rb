require 'rails_helper'

RSpec.describe "promo_codes#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/promo-codes", payload
  end

  describe 'basic create' do
    let(:params) do
      attributes_for(:promo_code)
    end
    let(:payload) do
      {
        data: {
          type: 'promo-codes',
          attributes: params
        }
      }
    end

    xit 'works' do
      expect(PromoCodeResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { PromoCode.count }.by(1)
    end
  end
end
