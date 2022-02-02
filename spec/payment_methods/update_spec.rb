require 'rails_helper'

RSpec.describe "payment_methods#update", type: :request do
  subject(:make_request) do
    jsonapi_put "//payment_methods/#{payment_method.id}", payload
  end

  describe 'basic update' do
    let!(:payment_method) { create(:payment_method) }

    let(:payload) do
      {
        data: {
          id: payment_method.id.to_s,
          type: 'payment_methods',
          attributes: {
            # ... your attrs here
          }
        }
      }
    end

    # Replace 'xit' with 'it' after adding attributes
    xit 'updates the resource' do
      expect(PaymentMethodResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { payment_method.reload.attributes }
    end
  end
end
