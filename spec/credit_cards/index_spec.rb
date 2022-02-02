require 'rails_helper'

RSpec.describe "credit_cards#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/payment-methods", params: params
  end

  describe 'basic fetch' do
    let!(:credit_card1) { create(:credit_card) }
    let!(:credit_card2) { create(:credit_card) }

    it 'works' do
      expect(PaymentMethodResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['credit-cards'])
      expect(d.map(&:id)).to match_array([credit_card1.id, credit_card2.id])
    end
  end
end
