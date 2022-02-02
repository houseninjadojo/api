require 'rails_helper'

RSpec.describe "credit_cards#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/payment-methods/#{credit_card.id}", payload
  end

  describe 'basic update' do
    let!(:credit_card) { create(:credit_card) }

    let(:payload) do
      {
        data: {
          id: credit_card.id.to_s,
          type: 'credit-cards',
          attributes: {
            'zipcode': '12345',
          }
        }
      }
    end

    # Replace 'xit' with 'it' after adding attributes
    it 'updates the resource' do
      expect(PaymentMethodResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { credit_card.reload.attributes }
    end
  end
end
