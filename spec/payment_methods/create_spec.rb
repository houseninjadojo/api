require 'rails_helper'

RSpec.describe "payment_methods#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/payment_methods", payload
  end

  describe 'basic create' do
    let(:params) do
      attributes_for(:credit_card)
    end
    let(:payload) do
      {
        data: {
          type: 'credit_cards',
          attributes: params
        }
      }
    end

    xit 'works' do
      expect(PaymentMethodResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { PaymentMethod.count }.by(1)
    end
  end
end
