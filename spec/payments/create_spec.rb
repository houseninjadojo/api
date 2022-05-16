require 'rails_helper'

RSpec.describe "payments#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/payments", payload
  end

  describe 'basic create' do
    let(:params) do
      attributes_for(:payment)
    end
    let(:payload) do
      {
        data: {
          type: 'payments',
          attributes: params
        }
      }
    end

    it 'works' do
      expect(PaymentResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { Payment.count }.by(1)
    end
  end
end
