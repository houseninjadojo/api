require 'rails_helper'

RSpec.describe "credit_cards#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/payment-methods", payload
  end

  describe 'basic create' do
    let(:user) { create(:user) }
    let(:params) do
      attributes_for(:credit_card).without(:stripe_token)
    end
    let(:payload) do
      {
        data: {
          type: 'credit-cards',
          attributes: params,
          relationships: {
            user: {
              data: {
                type: 'users',
                id: user.id
              }
            }
          }
        }
      }
    end

    it 'works' do
      expect(PaymentMethodResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { CreditCard.count }.by(1)
    end
  end
end
