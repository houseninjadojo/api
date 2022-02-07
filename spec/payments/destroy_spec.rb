require 'rails_helper'

RSpec.describe "payments#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/payments/#{payment.id}"
  end

  describe 'basic destroy' do
    let!(:payment) { create(:payment) }

    xit 'updates the resource' do
      expect(PaymentResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { Payment.count }.by(-1)
      expect { payment.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
