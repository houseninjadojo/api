require 'rails_helper'

RSpec.describe "credit_cards#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/payment-methods/#{credit_card.id}", params: params
  end

  describe 'basic fetch' do
    let!(:credit_card) { create(:credit_card) }

    it 'works' do
      expect(PaymentMethodResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('credit-cards')
      expect(d.id).to eq(credit_card.id)
    end
  end
end
