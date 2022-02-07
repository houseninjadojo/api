require 'rails_helper'

RSpec.describe "payments#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/payments/#{payment.id}", payload
  end

  describe 'basic update' do
    let!(:payment) { create(:payment) }

    let(:payload) do
      {
        data: {
          id: payment.id.to_s,
          type: 'payments',
          attributes: {
            # ... your attrs here
          }
        }
      }
    end

    # Replace 'xit' with 'it' after adding attributes
    xit 'updates the resource' do
      expect(PaymentResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { payment.reload.attributes }
    end
  end
end
