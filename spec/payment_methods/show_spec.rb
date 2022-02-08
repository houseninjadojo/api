require 'rails_helper'

RSpec.describe "payment_methods#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/payment-methods/#{payment_method.id}", params: params
  end

  describe 'basic fetch' do
    let!(:user) { create(:user) }
    let!(:payment_method) { create(:payment_method, user: user) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    xit 'works' do
      expect(PaymentMethodResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('payment_methods')
      expect(d.id).to eq(payment_method.id)
    end
  end
end
