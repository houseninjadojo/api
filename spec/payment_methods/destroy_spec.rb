require 'rails_helper'

RSpec.describe "payment_methods#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "//payment_methods/#{payment_method.id}"
  end

  describe 'basic destroy' do
    let!(:payment_method) { create(:payment_method) }

    xit 'updates the resource' do
      expect(PaymentMethodResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { PaymentMethod.count }.by(-1)
      expect { payment_method.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
